package com.bytebridges.anytop.service.ussd;

import org.springframework.stereotype.Service;

import com.bytebridges.anytop.config.EloadConfig;
import com.bytebridges.anytop.dto.Message;
import com.bytebridges.anytop.enums.MytelAmount;
import com.bytebridges.anytop.enums.TxnStatus;
import com.bytebridges.anytop.service.UssdTopupService;
import com.bytebridges.anytop.service.external.UssdGatewayClient;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service("MYTEL")
@RequiredArgsConstructor
@Slf4j
public class MytelTopupUssdService implements UssdTopupService {

	private final UssdGatewayClient client;
	private final EloadConfig config;

	@Override
	public TxnStatus topup(Long txnId, String port, String password, String mobile, String amount) {

		long startTime = System.currentTimeMillis();

		String maskedMobile = mask(mobile);
		
		log.info("MYTEL_TOPUP_STARTED txId={} port={} mobile={} amount={}", txnId, port, maskedMobile, amount);

		try {

			Message response;

			// =========================================================
			// STEP 1 : *888#
			// =========================================================
			String step1Request = "*888#";

			log.debug("MYTEL_STEP1_REQUEST txId={} request={}", txnId, step1Request);

			long t1 = System.currentTimeMillis();

			//response = call(port, step1Request);
			response = call(port, step1Request);

			long d1 = System.currentTimeMillis() - t1;

			log.debug("MYTEL_STEP1_RESPONSE txId={} port={} mobile={} durationMs={} response={}", txnId, port, maskedMobile, d1, safeResp(response));

			if (isInvalid(response)) {
				return fail(txnId, port, maskedMobile, "STEP1");
			}

			// =========================================================
			// STEP 2 : SELL
			// =========================================================
			
			String step2Request = "1";

			log.debug("MYTEL_STEP2_REQUEST txId={} request={}", txnId, step2Request);

			long t2 = System.currentTimeMillis();

			response = call(port, step2Request);

			long d2 = System.currentTimeMillis() - t2;

			log.debug("MYTEL_STEP2_RESPONSE txId={} port={} mobile={} durationMs={} response={}", txnId, port,
					maskedMobile, d2, safeResp(response));

			if (isInvalid(response)) {
				return fail(txnId, port, maskedMobile, "STEP2");
			}

			// =========================================================
			// STEP 3 : ELOAD
			// =========================================================
			String step3Request = "1";
			log.debug("MYTEL_STEP3_REQUEST txId={} request={}", txnId, step3Request);

			long t3 = System.currentTimeMillis();

			response = call(port, step3Request);

			long d3 = System.currentTimeMillis() - t3;

			log.debug("MYTEL_STEP3_RESPONSE txId={} port={} mobile={} durationMs={} response={}", txnId, port, maskedMobile, d3, safeResp(response));
 
			if (isInvalid(response)) {
				return fail(txnId, port, maskedMobile, "STEP3");
			}

			// =========================================================
			// STEP 4 : PHONE
			// =========================================================

			log.debug("MYTEL_STEP4_REQUEST txId={} request={}", txnId, mobile);

			long t4 = System.currentTimeMillis();

			response = call(port, mobile);

			long d4 = System.currentTimeMillis() - t4;

			log.debug("MYTEL_STEP4_RESPONSE txId={} port={} mobile={} durationMs={} response={}", txnId, port,
					maskedMobile, d4, safeResp(response));

			if (isInvalid(response)) {
				return fail(txnId, port, maskedMobile, "STEP4");
			}

			// =========================================================
			// STEP 5 : AMOUNT
			// =========================================================

			String amountCode = MytelAmount.fromAmount(amount);

			log.debug("MYTEL_STEP5_REQUEST txId={} request={}", txnId, amountCode);

			long t5 = System.currentTimeMillis();

			response = call(port, amountCode);

			long d5 = System.currentTimeMillis() - t5;

			log.debug("MYTEL_STEP5_RESPONSE txId={} port={} mobile={} durationMs={} response={}", txnId, port,
					maskedMobile, d5, safeResp(response));

			if (isInvalid(response)) {
				return fail(txnId, port, maskedMobile, "STEP5");
			}

			// =========================================================
			// STEP 6 : PASSWORD
			// =========================================================

			log.debug("MYTEL_STEP6_REQUEST txId={}request={}", txnId, password);

			long t6 = System.currentTimeMillis();

			response = call(port, password);

			long d6 = System.currentTimeMillis() - t6;

			log.debug("MYTEL_STEP6_RESPONSE txId={} port={} mobile={} durationMs={} response={}", txnId, port,
					maskedMobile, d6, safeResp(response));

			if (isInvalid(response)) {
				return fail(txnId, port, maskedMobile, "STEP6");
			}

			// =========================================================
			// STEP 7 : CONFIRM
			// =========================================================
			String step7Request = "1";
			log.debug("MYTEL_STEP7_REQUEST txId={} request={}", txnId, step7Request);

			long t7 = System.currentTimeMillis();

			response = call(port, step7Request);

			long d7 = System.currentTimeMillis() - t7;

			log.debug("MYTEL_STEP7_RESPONSE txId={} port={} mobile={} durationMs={} response={}", txnId, port, maskedMobile, d7, safeResp(response));

			// =========================================================
			// FINAL RESULT
			// =========================================================

			long totalTime = System.currentTimeMillis() - startTime;

			if (isSuccess(response)) {

				log.info("MYTEL_TOPUP_SUCCESS txId={} port={} mobile={} amount={} totalDurationMs={}", txnId, port, maskedMobile, amount, totalTime);

				return TxnStatus.SUCCESS;
			}

			log.warn("MYTEL_TOPUP_FAILED txId={} port={} mobile={} amount={} totalDurationMs={}", txnId, port, maskedMobile, amount, totalTime);

			return TxnStatus.FAILED;

		} catch (Exception e) {

			long totalTime = System.currentTimeMillis() - startTime;

			log.error("MYTEL_TOPUP_ERROR txId={} port={} mobile={} durationMs={} errorType={}", txnId, port, maskedMobile, totalTime, e.getClass().getSimpleName(), e);

			return TxnStatus.FAILED;
		}
	}

	// =========================================================
	// UNIFIED USSD CALL
	// =========================================================

	private Message call(String port, String ussd) {
		return client.call(config.getEndpoints().getUssdGateway(), port, ussd);
	}

	// =========================================================
	// INVALID RESPONSE CHECK
	// =========================================================

	private boolean isInvalid(Message msg) {
		return msg == null || msg.getResp() == null;
	}

	// =========================================================
	// STEP FAILURE
	// =========================================================

	private TxnStatus fail(Long txnId, String port, String mobile, String step) {

		log.warn("MYTEL_{}_FAILED txId={} port={} mobile={} reason=NULL_RESPONSE", step, txnId, port, mobile);

		return TxnStatus.FAILED;
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