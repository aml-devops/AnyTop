package com.bytebridges.anytop.service.external;

import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import com.bytebridges.anytop.dto.Message;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UssdGatewayClient {

    private final WebClient webClient;

    public Message call(String url) {

        try {
            String response = webClient.get()
                    .uri(url)
                    .retrieve()
                    .bodyToMono(String.class)
                    .block();

            ObjectMapper mapper = new ObjectMapper();
            return mapper.readValue(response, Message.class);

        } catch (Exception e) {
            throw new RuntimeException("USSD Gateway error", e);
        }
    }
}
