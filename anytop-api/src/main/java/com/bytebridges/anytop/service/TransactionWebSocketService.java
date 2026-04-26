package com.bytebridges.anytop.service;

import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import com.bytebridges.anytop.dto.TransactionUpdate;

@Service
@RequiredArgsConstructor
public class TransactionWebSocketService {

    private final SimpMessagingTemplate messagingTemplate;

    public void sendUpdate(TransactionUpdate update) {

        messagingTemplate.convertAndSend(
                "/topic/transactions",
                update
        );
    }
}
