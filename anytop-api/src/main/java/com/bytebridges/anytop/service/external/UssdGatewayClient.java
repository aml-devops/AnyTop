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
    private final ObjectMapper mapper = new ObjectMapper();

    public Message call(String path,
                        String port,
                        String ussd) {

        try {
            String response = webClient.get()
                    .uri(uriBuilder -> uriBuilder
                            .path(path)
                            .queryParam("username", "root")
                            .queryParam("password", "root")
                            .queryParam("port", port)
                            .queryParam("ussd", ussd)
                            .build()
                    )
                    .retrieve()
                    .bodyToMono(String.class)
                    .block();

            return mapper.readValue(response, Message.class);

        } catch (Exception e) {
            throw new RuntimeException("USSD Gateway error", e);
        }
    }
}