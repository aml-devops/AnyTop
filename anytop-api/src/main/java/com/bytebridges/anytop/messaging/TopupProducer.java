package com.bytebridges.anytop.messaging;

import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Component;

import com.bytebridges.anytop.dto.TopupMessage;

import java.util.UUID;

@Slf4j
@Component
public class TopupProducer {

    private final RabbitTemplate rabbitTemplate;

    public TopupProducer(RabbitTemplate rabbitTemplate) {
        this.rabbitTemplate = rabbitTemplate;
    }

    public void send(TopupMessage message) {

        // 🧠 Ensure messageId exists
        if (message.getMessageId() == null) {
            message.setMessageId(UUID.randomUUID().toString());
        }

        log.info("🚀 [PRODUCER] Preparing message | txnId={} | messageId={} | operator={}",
                message.getTxnId(),
                message.getMessageId(),
                message.getOperator());

        rabbitTemplate.convertAndSend("TOPUP_QUEUE", message);

        log.info("📤 [PRODUCER] Message sent | txnId={} | messageId={} | queue=TOPUP_QUEUE",
                message.getTxnId(),
                message.getMessageId());
    }
}