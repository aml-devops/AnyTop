package com.bytebridges.anytop.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import lombok.Data;

@Data
@Component
@ConfigurationProperties(prefix = "eload")
public class EloadConfig {

    private String username;
    private String password;
    private String ussdGateway;
    private String getStatus;
    private String sendCmd;
    private String postSms;
}
