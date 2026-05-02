package com.bytebridges.anytop.messaging;

import java.util.UUID;

import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Component;

import com.bytebridges.anytop.dto.TopupMessage;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RequiredArgsConstructor
@Slf4j
@Component
public class TopupProducer {

	private final RabbitTemplate rabbitTemplate;
	public static final String TOPUP_QUEUE = "TOPUP_QUEUE";

	public void send(TopupMessage message) {

		long start = System.currentTimeMillis();

		if (message.getMessageId() == null) {
			message.setMessageId(UUID.randomUUID().toString());
		}

		//log.info("TOPUP_PRODUCER_PREPARE txnId={} messageId={} operator={}", message.getTxnId(), message.getMessageId(), message.getOperator());

		try {
			rabbitTemplate.convertAndSend(TOPUP_QUEUE, message);

			long duration = System.currentTimeMillis() - start;

			log.info("TOPUP_PRODUCER_SENT txnId={} messageId={} queue={} durationMs={}", message.getTxnId(), message.getMessageId(), TOPUP_QUEUE, duration);

		} catch (Exception ex) {

			long duration = System.currentTimeMillis() - start;

			log.error("TOPUP_PRODUCER_FAILED txnId={} messageId={} queue={} durationMs={}", message.getTxnId(),
					message.getMessageId(), TOPUP_QUEUE, duration, ex);

			throw ex; // or retry logic
		}
	}
}