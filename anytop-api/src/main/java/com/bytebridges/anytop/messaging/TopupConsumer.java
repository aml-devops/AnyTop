package com.bytebridges.anytop.messaging;

import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

import com.bytebridges.anytop.dto.TopupMessage;
import com.bytebridges.anytop.entity.Transaction;
import com.bytebridges.anytop.repository.TransactionRepository;
import com.bytebridges.anytop.service.EloadTopupService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RequiredArgsConstructor
@Slf4j
@Component
public class TopupConsumer {

	private final TransactionRepository txnRepo;
	private final EloadTopupService eloadTopupService;

	@RabbitListener(queues = "TOPUP_QUEUE")
	public void process(TopupMessage message) {

		long start = System.currentTimeMillis();

		log.info("TOPUP_CONSUMER_RECEIVED txnId={} operator={} messageId={}", message.getTxnId(), message.getOperator(), message.getMessageId());

		try {

			Transaction txn = txnRepo.findById(message.getTxnId())
					.orElseThrow(() -> new RuntimeException("Transaction not found"));

			log.debug("TOPUP_CONSUMER_PROCESSING txnId={} status={}", txn.getId(), txn.getStatus());

			// FAST DB UPDATE
			eloadTopupService.startProcessing(txn);

			// SLOW EXTERNAL PROCESS
			eloadTopupService.processTopup(txn);

			long duration = System.currentTimeMillis() - start;

			log.info("TOPUP_CONSUMER_COMPLETED txnId={} status={} durationMs={}", txn.getId(), txn.getStatus(), duration);

		} catch (Exception ex) {

			long duration = System.currentTimeMillis() - start;

			log.error("TOPUP_CONSUMER_FAILED txnId={} messageId={} durationMs={}", message.getTxnId(), message.getMessageId(), duration, ex);

			throw ex;
		}
	}
}