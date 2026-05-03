package com.bytebridges.anytop.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.bytebridges.anytop.common.ServiceResponse;
import com.bytebridges.anytop.dto.OperatorBalanceDto;
import com.bytebridges.anytop.dto.OperatorBalanceResponseDto;
import com.bytebridges.anytop.dto.PaginationDto;
import com.bytebridges.anytop.dto.TopupMessage;
import com.bytebridges.anytop.dto.TopupResponseDto;
import com.bytebridges.anytop.dto.TransactionPageResponseDto;
import com.bytebridges.anytop.dto.TransactionResponseDto;
import com.bytebridges.anytop.dto.TransactionUpdate;
import com.bytebridges.anytop.entity.SimCard;
import com.bytebridges.anytop.entity.Transaction;
import com.bytebridges.anytop.enums.Operator;
import com.bytebridges.anytop.enums.SimStatus;
import com.bytebridges.anytop.enums.TxnStatus;
import com.bytebridges.anytop.messaging.TopupProducer;
import com.bytebridges.anytop.repository.SimCardRepository;
import com.bytebridges.anytop.repository.TransactionRepository;
import com.bytebridges.anytop.service.router.UssdTopupEngine;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class TransactionService {
	private final TransactionRepository transactionRepository;
	private final SimCardRepository simCardRepository;
	private final TopupProducer producer;
	private final TransactionWebSocketService wsService;
	private final UssdTopupEngine ussdTopupEngine;

	private static final long THRESHOLD = 1000;

	// =========================================================
	// 🟢 PRODUCER
	// =========================================================
	public TopupResponseDto createTopup(String operator, String phone, Integer amount) {

		log.info("TOPUP_REQUEST_ACCEPTED operator={} phone={} amount={}", operator, maskPhone(phone), amount);

		Transaction txn = new Transaction();
		txn.setPhoneNumber(phone);
		txn.setAmount(amount);
		txn.setOperator(operator);
		txn.setStatus("PENDING");
		txn.setCreatedAt(LocalDateTime.now());
		txn = transactionRepository.save(txn);

		String messageId = UUID.randomUUID().toString();
		txn.setMessageId(messageId);
		txn.setStatus("SENT_TO_QUEUE");
		transactionRepository.save(txn);

		// Topup producer
		producer.send(new TopupMessage(txn.getId(), operator, messageId));

		return toResponse(txn);
	}

	// =========================================================
	// 🟡 CONSUMER
	// =========================================================
	@Transactional
	public void processTopup(Transaction txn) {

		/**
		 * log.info("⚙️ Process start | txnId={}", txn.getId());
		 * 
		 * // Idempotency check if ("SUCCESS".equals(txn.getStatus())) { log.warn("⚠️
		 * Already processed | txnId={}", txn.getId()); return; }
		 * 
		 * wsService.sendUpdate(new TransactionUpdate(txn.getId(), "PROCESSING", null,
		 * "Started"));
		 * 
		 * txn.setStatus("PROCESSING"); txnRepo.save(txn);
		 */

		SimCard sim = null;

		try {

			long startTime = System.currentTimeMillis();

			// log.info("[TOPUP][START] txnId={} | operator={} | mobile={} | amount={}",
			// txn.getId(), txn.getOperator(), txn.getPhoneNumber(), txn.getAmount());

			// STEP 1 : Select & Lock SIM
			sim = selectAndLockSim(txn.getOperator(), txn.getAmount());

			log.info("ELOAD_SIM_SELECTED txnId={} operator={} simId={} port={}", txn.getId(), txn.getOperator(),
					sim.getId(), sim.getSimName());

			wsService.sendUpdate(new TransactionUpdate(txn.getId(), "SIM_SELECTED", sim.getSimName(), "Locked SIM"));

			// STEP 2 : Execute USSD Topup
			log.info("ELOAD_USSD_REQUEST txnId={} operator={} port={} mobile={} amount={}", txn.getId(),
					txn.getOperator(), sim.getSimName(), txn.getPhoneNumber(), txn.getAmount());

			TxnStatus result = ussdTopupEngine.route(Operator.from(txn.getOperator()), txn.getId(), sim.getSimName(),
					sim.getPassword(), txn.getPhoneNumber(), String.valueOf(txn.getAmount()));

			boolean success = result == TxnStatus.SUCCESS;

			log.info("ELOAD_USSD_RESPONSE txnId={} operator={} result={}", txn.getId(), txn.getOperator(), result);

			txn.setSimId(sim.getId());
			txn.setStatus(success ? "SUCCESS" : "FAILED");

			if (success) {

				// STEP 3 : Deduct SIM Balance
				sim.setBalance(sim.getBalance() - txn.getAmount());
				simCardRepository.save(sim);

				log.info("ELOAD_USSD_SUCCESS txnId={} operator={} simId={} remainingBalance={}", txn.getId(),
						txn.getOperator(), sim.getId(), sim.getBalance());

				wsService.sendUpdate(new TransactionUpdate(txn.getId(), "SUCCESS", sim.getSimName(), "Completed"));

			} else {

				log.warn("ELOAD_USSD_FAILED txnId={} operator={} simId={} reason=USSD_FAILED", txn.getId(),
						txn.getOperator(), sim.getId());

				wsService.sendUpdate(new TransactionUpdate(txn.getId(), "FAILED", sim.getSimName(), "Failed"));
			}

			long duration = System.currentTimeMillis() - startTime;

			log.info("ELOAD_COMPLETED txnId={} operator={} status={} durationMs={}", txn.getId(), txn.getOperator(),
					txn.getStatus(), duration);

		} catch (Exception ex) {

			txn.setStatus("FAILED");

			log.error("ELOAD_ERROR txnId={} operator={} errorType={} message={}", txn.getId(), txn.getOperator(),
					ex.getClass().getSimpleName(), ex.getMessage(), ex);

		} finally {

			if (sim != null) {

				releaseSim(sim.getId());

				log.info("ELOAD_SIM_RELEASED txnId={} simId={} port={}", txn.getId(), sim.getId(), sim.getSimName());
			}

			transactionRepository.save(txn);

			log.info("TOPUP_TXN_SAVED txnId={} status={}", txn.getId(), txn.getStatus());
		}
	}

	@Transactional
	public void startProcessing(Transaction txn) {

		// log.info("TOPUP_START txnId={}", txn.getId());

		// Idempotency check
		if ("SUCCESS".equals(txn.getStatus())) {
			log.warn("TOPUP_ALREADY_PROCESSED txnId={}", txn.getId());
			return;
		}

		txn.setStatus("PROCESSING");
		transactionRepository.save(txn);
	}

	// =========================================================
	// 🔐 SIM SELECTION + LOCK
	// =========================================================
	private SimCard selectAndLockSim(String operator, Integer amount) {

		long required = (long) amount + THRESHOLD;

		List<SimCard> sims = simCardRepository.findEligibleSims(operator, required, THRESHOLD);

		for (SimCard sim : sims) {

			int locked = simCardRepository.lockSim(sim.getId());

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

		simCardRepository.findById(simId).ifPresent(sim -> {

			sim.setStatus(SimStatus.FREE);
			sim.setLastUsedAt(LocalDateTime.now());

			simCardRepository.save(sim);

			// log.info("🔓 SIM released | simId={}", simId);
		});
	}

	// =========================================================
	// 📊 QUERY
	// =========================================================
	public Transaction getTransactionById(Long id) {
		return transactionRepository.findById(id).orElseThrow(() -> new RuntimeException("Transaction not found"));
	}

	private String maskPhone(String phone) {
		if (phone == null || phone.length() < 5)
			return "****";
		return phone.substring(0, 3) + "****" + phone.substring(phone.length() - 2);
	}

	public TopupResponseDto toResponse(Transaction txn) {

		return TopupResponseDto.builder().txnId(txn.getId()).status(txn.getStatus())
				.message("Topup request accepted and queued for processing").operator(txn.getOperator())
				.phoneNumber(maskPhone(txn.getPhoneNumber())).amount(txn.getAmount()).messageId(txn.getMessageId())
				.createdAt(txn.getCreatedAt()).build();
	}

	public ServiceResponse<?> getTransactionsByCreatedAt(LocalDateTime startDate, LocalDateTime endDate, int page,
			int size) {

		try {

			Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));

			Page<Transaction> transactionPage = transactionRepository.findByCreatedAtBetween(startDate, endDate,
					pageable);

			List<TransactionResponseDto> items = transactionPage.getContent().stream().map(this::mapToDto).toList();

			PaginationDto pagination = new PaginationDto(transactionPage.getNumber(), transactionPage.getSize(),
					transactionPage.getTotalElements(), transactionPage.getTotalPages(), transactionPage.isFirst(),
					transactionPage.isLast());

			TransactionPageResponseDto response = new TransactionPageResponseDto(items, pagination);

			log.info("Transactions fetched successfully | page={} | size={} | totalElements={}", page, size,
					transactionPage.getTotalElements());

			return ServiceResponse.success(response, "Transactions fetched successfully");

		} catch (Exception e) {

			log.error("Failed to fetch transactions", e);

			return ServiceResponse.error(500, "Failed to fetch transactions");
		}
	}

	private TransactionResponseDto mapToDto(Transaction transaction) {

		return new TransactionResponseDto(transaction.getId(), transaction.getPhoneNumber(), transaction.getAmount(),
				transaction.getOperator(), transaction.getStatus(), transaction.getSimId(), transaction.getMessageId(),
				transaction.getCreatedAt());
	}
}