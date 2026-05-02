package com.bytebridges.anytop.service.ussd;

import org.springframework.stereotype.Service;

import com.bytebridges.anytop.config.EloadConfig;
import com.bytebridges.anytop.dto.Message;
import com.bytebridges.anytop.enums.TxnStatus;
import com.bytebridges.anytop.service.UssdTopupService;
import com.bytebridges.anytop.service.external.UssdGatewayClient;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service("U9")
@RequiredArgsConstructor
@Slf4j
public class U9TopupUssdService implements UssdTopupService {

	private final UssdGatewayClient client;
	private final EloadConfig config;

	@Override
	public TxnStatus topup(Long txnId, String port, String password, String mobile, String amount) {

		long startTime = System.currentTimeMillis();

		String maskedMobile = mask(mobile);
		
		log.info("U9_TOPUP_STARTED txId={} port={} mobile={} amount={}", txnId, port, maskedMobile, amount);

		try {

			// =========================================================
			// STEP 1
			// =========================================================

			String ussd = "*116*1*" + mobile + "*" + amount + "*"+ password + "*1#";

			log.debug("U9_STEP1_REQUEST txId={} port={} mobile={} amount={}", txnId, port, maskedMobile, amount);

			long t1 = System.currentTimeMillis();

			Message response = client.call(config.getEndpoints().getUssdGateway(), port, ussd);

			long d1 = System.currentTimeMillis() - t1;

			log.debug("U9_STEP1_RESPONSE txId={} port={} mobile={} durationMs={} response={}", txnId, port,
					maskedMobile, d1, safeResp(response));

			if (response == null || response.getResp() == null) {

				log.warn("U9_TOPUP_STEP1_FAILED txId={} port={} mobile={} reason=NULL_RESPONSE", txnId, port,
						maskedMobile);

				return TxnStatus.FAILED;
			}

			// =========================================================
			// FINAL RESULT
			// =========================================================

			long totalTime = System.currentTimeMillis() - startTime;

			if (isSuccess(response)) {

				log.info("U9_TOPUP_SUCCESS txId={} port={} mobile={} amount={} totalDurationMs={}", txnId, port,
						maskedMobile, amount, totalTime);

				return TxnStatus.SUCCESS;
			}

			log.warn("U9_TOPUP_FAILED txId={} port={} mobile={} amount={} totalDurationMs={}", txnId, port,
					maskedMobile, amount, totalTime);

			return TxnStatus.FAILED;

		} catch (Exception e) {

			long totalTime = System.currentTimeMillis() - startTime;

			log.error("U9_TOPUP_ERROR txId={} port={} mobile={} durationMs={} errorType={}", txnId, port, maskedMobile,
					totalTime, e.getClass().getSimpleName(), e);

			return TxnStatus.FAILED;
		}
	}

	// =========================================================
	// SAFE RESPONSE
	// =========================================================

	private String safeResp(Message msg) {
		return (msg != null && msg.getResp() != null) ? msg.getResp() : "NULL";
	}

	// =========================================================
	// MOBILE MASKING
	// =========================================================

	private String mask(String mobile) {

		if (mobile == null || mobile.length() < 4) {
			return "****";
		}

		return "****" + mobile.substring(mobile.length() - 4);
	}

	// =========================================================
	// SUCCESS VALIDATION
	// =========================================================

	private boolean isSuccess(Message msg) {

		String resp = safeResp(msg).toLowerCase();

		return !(resp.contains("fail") || resp.contains("error"));
	}
}