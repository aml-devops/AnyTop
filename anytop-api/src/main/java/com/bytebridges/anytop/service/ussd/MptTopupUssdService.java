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
            //String step1Request = build(port, "*125*" + amount + "*" + mobile + "*8899#");
            String ussd = "*125*" + amount + "*" + mobile + "*8899#";
            log.info("MPT Step1 Request | mobile={} | req={}", mobile, ussd);

            Message pre = client.call("/goip_send_ussd.html", port, ussd);
            log.info("MPT Step1 Response | mobile={} | message={}", mobile, pre);

            if (pre == null || pre.getResp() == null) {
                log.error("MPT Step1 failed | mobile={} | message={}", mobile, pre);
                return TxnStatus.FAILED;
            }

            // Step 2
            String step2Request = build(port, "1");
            String ussd1 = "1";
            log.info("MPT Step2 Request | mobile={} | req={}", mobile, step2Request);

            Message confirm = client.call("/goip_send_ussd.html", port, ussd1);
            log.info("MPT Step2 Response | mobile={} | message={}", mobile, confirm);

            if (confirm == null || confirm.getResp() == null) {
                log.error("MPT Step2 failed | mobile={} | message={}", mobile, confirm);
                return TxnStatus.FAILED;
            }

            // Step 3 (optional confirm)
            if (needSecondConfirm(confirm)) {
                log.info("MPT يحتاج Second Confirm | mobile={}", mobile);

                confirm = client.call("/goip_send_ussd.html", port, ussd1);
                log.info("MPT Step3 Response | mobile={} | message={}", mobile, confirm);
            }

            // Final validation
            if (isSuccess(confirm)) {
                log.info("MPT SUCCESS | mobile={} | finalResp={}", mobile, confirm.getResp());
                return TxnStatus.SUCCESS;
            } else {
                log.error("MPT FAILED | mobile={} | finalResp={}", mobile, confirm.getResp());
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
                "&ussd=" + ussd;
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
