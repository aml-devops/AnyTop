package com.bytebridges.anytop.service.external;

import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import com.bytebridges.anytop.config.EloadConfig;
import com.bytebridges.anytop.dto.Message;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class UssdGatewayClient {

    private final WebClient webClient;
    private final ObjectMapper mapper;
    private final EloadConfig config;

    public Message call(String path, String port, String ussd) {

        try {
            String response = webClient.get()
                    .uri(uriBuilder -> uriBuilder
                            .path(path)
                            .queryParam("username", config.getUsername())
                            .queryParam("password", config.getPassword())
                            .queryParam("port", port)
                            .queryParam("ussd", ussd)
                            .build()
                    )
                    .retrieve()
                    .onStatus(
                            status -> status.isError(),
                            clientResponse -> clientResponse.bodyToMono(String.class)
                                    .map(body -> new RuntimeException("USSD error response: " + body))
                    )
                    .bodyToMono(String.class)
                    .block();

            log.info("USSD Response | port={} | response={}", port, response);

            return mapper.readValue(response, Message.class);

        } catch (Exception e) {
            log.error("USSD Gateway error | port={} | ussd={}", port, ussd, e);
            throw new RuntimeException("USSD Gateway error", e);
        }
    }
}