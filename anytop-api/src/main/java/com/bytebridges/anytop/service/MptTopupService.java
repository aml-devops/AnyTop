package com.bytebridges.anytop.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.bytebridges.anytop.dto.TopupMessage;
import com.bytebridges.anytop.dto.TransactionUpdate;
import com.bytebridges.anytop.entity.SimCard;
import com.bytebridges.anytop.entity.Transaction;
import com.bytebridges.anytop.enums.SimStatus;
import com.bytebridges.anytop.enums.TxnStatus;
import com.bytebridges.anytop.messaging.TopupProducer;
import com.bytebridges.anytop.repository.SimCardRepository;
import com.bytebridges.anytop.repository.TransactionRepository;
import com.bytebridges.anytop.service.ussd.MptTopupUssdService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class MptTopupService {

    private final TransactionRepository txnRepo;
    private final SimCardRepository simRepo;
    private final TopupProducer producer;
    private final TransactionWebSocketService wsService;
    private final MptTopupUssdService ussdService;

    private static final long THRESHOLD = 1000;

    // =========================================================
    // 🟢 PRODUCER
    // =========================================================
    public Transaction createTopup(String phone, Integer amount) {

        log.info("🚀 Create topup | phone={} | amount={}", phone, amount);

        Transaction txn = new Transaction();
        txn.setPhoneNumber(phone);
        txn.setAmount(amount);
        txn.setOperator("MPT");
        txn.setStatus("PENDING");
        txn.setCreatedAt(LocalDateTime.now());

        txn = txnRepo.save(txn);

        String messageId = UUID.randomUUID().toString();

        txn.setMessageId(messageId);
        txn.setStatus("SENT_TO_QUEUE");
        txnRepo.save(txn);

        producer.send(new TopupMessage(txn.getId(), "MPT", messageId));

        log.info("📤 Sent to queue | txnId={}", txn.getId());

        return txn;
    }

    // =========================================================
    // 🟡 CONSUMER
    // =========================================================
    @Transactional
    public void processTopup(Transaction txn) {

        log.info("⚙️ Process start | txnId={}", txn.getId());

        // Idempotency check
        if ("SUCCESS".equals(txn.getStatus())) {
            log.warn("⚠️ Already processed | txnId={}", txn.getId());
            return;
        }

        wsService.sendUpdate(new TransactionUpdate(
                txn.getId(),
                "PROCESSING",
                null,
                "Started"
        ));

        txn.setStatus("PROCESSING");
        txnRepo.save(txn);

        SimCard sim = null;

        try {
            sim = selectAndLockSim("MPT", txn.getAmount());

            log.info("📶 SIM selected | simId={} | port={}", sim.getId(), sim.getSimName());

            wsService.sendUpdate(new TransactionUpdate(
                    txn.getId(),
                    "SIM_SELECTED",
                    sim.getSimName(),
                    "Locked SIM"
            ));

            // ✅ Call real USSD service
            TxnStatus result = ussdService.topup(
                    sim.getSimName(),
                    txn.getPhoneNumber(),
                    String.valueOf(txn.getAmount())
            );

            boolean success = result == TxnStatus.SUCCESS;

            txn.setSimId(sim.getId());
            txn.setStatus(success ? "SUCCESS" : "FAILED");

            if (success) {

                // ✅ Deduct SIM balance
                sim.setBalance(sim.getBalance() - txn.getAmount());
                simRepo.save(sim);

                log.info("✅ SUCCESS | txnId={}", txn.getId());

                wsService.sendUpdate(new TransactionUpdate(
                        txn.getId(),
                        "SUCCESS",
                        sim.getSimName(),
                        "Completed"
                ));

            } else {

                log.warn("⚠️ FAILED | txnId={}", txn.getId());

                wsService.sendUpdate(new TransactionUpdate(
                        txn.getId(),
                        "FAILED",
                        sim.getSimName(),
                        "Failed"
                ));
            }

        } catch (Exception ex) {

            log.error("❌ ERROR | txnId={} | msg={}", txn.getId(), ex.getMessage(), ex);
            txn.setStatus("FAILED");

        } finally {

            if (sim != null) {
                releaseSim(sim.getId());
            }

            txnRepo.save(txn);

            log.info("💾 Transaction saved | txnId={} | status={}",
                    txn.getId(), txn.getStatus());
        }
    }

    // =========================================================
    // 🔐 SIM SELECTION + LOCK
    // =========================================================
    private SimCard selectAndLockSim(String operator, Integer amount) {

        long required = (long) amount + THRESHOLD;

        List<SimCard> sims =
                simRepo.findEligibleSims(operator, required, THRESHOLD);

        for (SimCard sim : sims) {

            int locked = simRepo.lockSim(sim.getId());

            if (locked == 1) {
                sim.setStatus(SimStatus.BUSY);
                sim.setLastUsedAt(LocalDateTime.now());
                return sim;
            }
        }

        throw new RuntimeException("No SIM available for " + operator);
    }

    // =========================================================
    // 🔓 RELEASE SIM
    // =========================================================
    private void releaseSim(Long simId) {

        simRepo.findById(simId).ifPresent(sim -> {

            sim.setStatus(SimStatus.FREE);
            sim.setLastUsedAt(LocalDateTime.now());

            simRepo.save(sim);

            log.info("🔓 SIM released | simId={}", simId);
        });
    }

    // =========================================================
    // 📊 QUERY
    // =========================================================
    public Transaction getTransactionById(Long id) {
        return txnRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Transaction not found"));
    }
}