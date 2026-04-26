package com.bytebridges.anytop.messaging;

import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

import com.bytebridges.anytop.dto.TopupMessage;
import com.bytebridges.anytop.entity.Transaction;
import com.bytebridges.anytop.repository.TransactionRepository;
import com.bytebridges.anytop.service.MptTopupService;

@Slf4j
@Component
public class TopupConsumer {

    private final TransactionRepository txnRepo;
    private final MptTopupService service;

    public TopupConsumer(TransactionRepository txnRepo,
                         MptTopupService service) {
        this.txnRepo = txnRepo;
        this.service = service;
    }

    @RabbitListener(queues = "TOPUP_QUEUE")
    public void process(TopupMessage message) {

        log.info("📩 [CONSUMER] Message received | txnId={} | messageId={} | operator={}",
                message.getTxnId(),
                message.getMessageId(),
                message.getOperator());

        Transaction txn = txnRepo.findById(message.getTxnId())
                .orElseThrow(() -> new RuntimeException("Transaction not found"));

        log.info("🔍 [CONSUMER] Transaction loaded | txnId={} | status={}",
                txn.getId(),
                txn.getStatus());

        service.processTopup(txn);

        log.info("🏁 [CONSUMER] Processing completed | txnId={} | finalStatus={}",
                txn.getId(),
                txn.getStatus());
    }
}