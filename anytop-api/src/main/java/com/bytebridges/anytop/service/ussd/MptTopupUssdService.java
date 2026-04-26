package com.bytebridges.anytop.service.ussd;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import org.springframework.stereotype.Service;

import com.bytebridges.anytop.config.EloadConfig;
import com.bytebridges.anytop.dto.Message;
import com.bytebridges.anytop.enums.TxnStatus;
import com.bytebridges.anytop.service.external.UssdGatewayClient;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class MptTopupUssdService {

    private final UssdGatewayClient client;
    private final EloadConfig config;

    public TxnStatus topup(String port, String mobile, String amount) {

        try {
            // Step 1
            Message pre = client.call(build(port, "*125*" + amount + "*" + mobile + "*7789%23"));

            if (pre == null || pre.getResp() == null) {
                log.error("MPT Step1 failed | mobile={}", mobile);
                return TxnStatus.FAILED;
            }

            // Step 2
            Message confirm = client.call(build(port, "1"));

            if (confirm == null || confirm.getResp() == null) {
                log.error("MPT Step2 failed | mobile={}", mobile);
                return TxnStatus.FAILED;
            }

            // Step 3 (optional confirm)
            if (needSecondConfirm(confirm)) {
                confirm = client.call(build(port, "1"));
            }

            // ✅ Validate final response
            if (isSuccess(confirm)) {
                log.info("MPT SUCCESS for {}", mobile);
                return TxnStatus.SUCCESS;
            } else {
                log.error("MPT FAILED | mobile={} | resp={}", mobile, confirm.getResp());
                return TxnStatus.FAILED;
            }

        } catch (Exception e) {
            log.error("MPT ERROR | mobile={} | error={}", mobile, e.getMessage(), e);
            return TxnStatus.FAILED;
        }
    }

    private String build(String port, String ussd) {
        return config.getUssdGateway() +
                "username=" + config.getUsername() +
                "&password=" + config.getPassword() +
                "&port=" + port +
                "&ussd=" + URLEncoder.encode(ussd, StandardCharsets.UTF_8);
    }

    private boolean needSecondConfirm(Message msg) {
        return msg != null &&
               msg.getResp() != null &&
               msg.getResp().toLowerCase().contains("confirm");
    }

    private boolean isSuccess(Message msg) {
        return msg != null &&
               msg.getResp() != null &&
               msg.getResp().toLowerCase().contains("success");
    }
}
