package com.bytebridges.anytop.service.ussd;

import org.springframework.stereotype.Service;

import com.bytebridges.anytop.config.EloadConfig;
import com.bytebridges.anytop.dto.Message;
import com.bytebridges.anytop.enums.TxnStatus;
import com.bytebridges.anytop.service.UssdTopupService;
import com.bytebridges.anytop.service.external.UssdGatewayClient;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service("MPT")
@RequiredArgsConstructor
@Slf4j
public class MptTopupUssdService implements UssdTopupService {

	private final UssdGatewayClient client;
	private final EloadConfig config;

	public TxnStatus topup(Long txnId, String port, String password, String mobile, String amount) {

		long startTime = System.currentTimeMillis();
		String maskedMobile = mask(mobile);
		log.info("MPT_TOPUP_STARTED txId={} port={} mobile={} amount={}", txnId, port, maskedMobile, amount);

		try {
			// STEP 1
			String step1Request = "*125*" + amount + "*" + mobile + "*" + password + "#";
			log.debug("MPT_STEP1_REQUEST txId={} request={}", txnId, step1Request);
			long t1 = System.currentTimeMillis();
			
			Message pre = client.call(config.getEndpoints().getUssdGateway(), port, step1Request);
			log.debug("MPT_STEP1_RESPONSE txId={} durationMs={} response={}", txnId, System.currentTimeMillis() - t1, safeResp(pre));

			if (pre == null || pre.getResp() == null) {
				log.warn("MPT_STEP1_FAILED txId={} reason=NULL_RESPONSE", txnId);
				return TxnStatus.FAILED;
			}

			// STEP 2
			String step2Request = "1";
			log.debug("MPT_STEP2_REQUEST txId={} request={}", txnId, step2Request);
			long t2 = System.currentTimeMillis();
			
			Message confirm = client.call(config.getEndpoints().getUssdGateway(), port, step2Request);
			log.debug("MPT_STEP2_RESPONSE txId={} durationMs={} response={}", txnId, System.currentTimeMillis() - t2, safeResp(confirm));

			if (confirm == null || confirm.getResp() == null) {
				log.warn("MPT_STEP2_FAILED txId={} reason=NULL_RESPONSE", txnId);
				return TxnStatus.FAILED;
			}

			// STEP 3
			if (needSecondConfirm(confirm)) {
				log.debug("MPT_STEP3_REQUEST txId={} request={}", txnId, step2Request);
				long t3 = System.currentTimeMillis();

				confirm = client.call(config.getEndpoints().getUssdGateway(), port, step2Request);
				log.debug("MPT_STEP3_RESPONSE txId={} durationMs={} response={}", txnId, System.currentTimeMillis() - t3, safeResp(confirm));
			}

			long totalTime = System.currentTimeMillis() - startTime;

			if (isSuccess(confirm)) {
				log.info("MPT_TOPUP_SUCCESS txId={} durationMs={}", txnId, totalTime);
				return TxnStatus.SUCCESS;
			}

			log.warn("MPT_TOPUP_FAILED txId={} durationMs={} response={}", txnId, totalTime, safeResp(confirm));
			return TxnStatus.FAILED;

		} catch (Exception e) {
			long totalTime = System.currentTimeMillis() - startTime;
			log.error("MPT_TOPUP_ERROR txId={} operator={} durationMs={} errorType={}", txnId, totalTime, e.getClass().getSimpleName(), e);
			return TxnStatus.FAILED;
		}
	}

	// ✅ Safe response logging (avoid NPE)
	private String safeResp(Message msg) {
		return (msg != null && msg.getResp() != null) ? msg.getResp() : "NULL";
	}

	// ✅ Mask sensitive data
	private String mask(String mobile) {
		if (mobile == null || mobile.length() < 4)
			return "****";
		return "****" + mobile.substring(mobile.length() - 4);
	}

	private boolean needSecondConfirm(Message msg) {
		return safeResp(msg).toLowerCase().contains("confirm");
	}

	private boolean isSuccess(Message msg) {
		return safeResp(msg).toLowerCase().contains("success");
	}
}