package com.bytebridges.anytop.service.ussd;

import org.springframework.stereotype.Service;

import com.bytebridges.anytop.config.EloadConfig;
import com.bytebridges.anytop.dto.Message;
import com.bytebridges.anytop.enums.TxnStatus;
import com.bytebridges.anytop.service.UssdTopupService;
import com.bytebridges.anytop.service.external.UssdGatewayClient;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service("ATOM")
@RequiredArgsConstructor
@Slf4j
public class AtomTopupUssdService implements UssdTopupService {

	private final UssdGatewayClient client;
	private final EloadConfig config;

	@Override
	public TxnStatus topup(Long txnId, String port, String password, String mobile, String amount) {

		long startTime = System.currentTimeMillis();

		String maskedMobile = mask(mobile);
		
		log.info("ATOM_TOPUP_STARTED txId={} port={} mobile={} amount={}", txnId, port, maskedMobile, amount);

		try {

			Message response;

			// =========================================================
			// STEP 1
			// =========================================================

			String step1 = "*555*" + mobile + "*9#";

			log.debug("ATOM_STEP1_REQUEST txId={} port={} mobile={}", txnId, port, maskedMobile);

			long t1 = System.currentTimeMillis();

			response = client.call(config.getEndpoints().getUssdGateway(), port, step1);

			long d1 = System.currentTimeMillis() - t1;

			log.debug("ATOM_STEP1_RESPONSE txId={} port={} mobile={} durationMs={} response={}", txnId, port,
					maskedMobile, d1, safeResp(response));

			if (response == null || response.getResp() == null) {

				log.warn("ATOM_TOPUP_STEP1_FAILED txId={} port={} mobile={} reason=NULL_RESPONSE", txnId, port,
						maskedMobile);

				return TxnStatus.FAILED;
			}

			// =========================================================
			// STEP 2
			// =========================================================

			if (hasText(response, "amount")) {

				log.debug("ATOM_STEP2_REQUEST txId={} port={} mobile={} amount={}", txnId, port, maskedMobile, amount);

				long t2 = System.currentTimeMillis();

				response = client.call(config.getEndpoints().getUssdGateway(), port, amount);

				long d2 = System.currentTimeMillis() - t2;

				log.debug("ATOM_STEP2_RESPONSE txId={} port={} mobile={} durationMs={} response={}", txnId, port,
						maskedMobile, d2, safeResp(response));

				if (response == null || response.getResp() == null) {

					log.warn("ATOM_TOPUP_STEP2_FAILED txId={} port={} mobile={} reason=NULL_RESPONSE", txnId, port,
							maskedMobile);

					return TxnStatus.FAILED;
				}
			}

			// =========================================================
			// STEP 3
			// =========================================================

			if (hasText(response, "m-pin")) {

				log.debug("ATOM_STEP3_REQUEST txId={} port={} mobile={}", txnId, port, maskedMobile);

				long t3 = System.currentTimeMillis();

				response = client.call(config.getEndpoints().getUssdGateway(), port, password);

				long d3 = System.currentTimeMillis() - t3;

				log.debug("ATOM_STEP3_RESPONSE txId={} port={} mobile={} durationMs={} response={}", txnId, port,
						maskedMobile, d3, safeResp(response));

				// SECOND CONFIRMATION
				if (hasText(response, "m-pin")) {

					log.warn("ATOM_TOPUP_CONFIRM_RETRY txId={} port={} mobile={}", txnId, port, maskedMobile);

					long t4 = System.currentTimeMillis();

					response = client.call(config.getEndpoints().getUssdGateway(), port, password);

					long d4 = System.currentTimeMillis() - t4;

					log.debug("ATOM_STEP3_RETRY_RESPONSE txId={} port={} mobile={} durationMs={} response={}", txnId,
							port, maskedMobile, d4, safeResp(response));
				}
			}

			// =========================================================
			// FINAL RESULT
			// =========================================================

			long totalTime = System.currentTimeMillis() - startTime;

			if (isSuccess(response)) {

				log.info("ATOM_TOPUP_SUCCESS txId={} port={} mobile={} amount={} totalDurationMs={}", txnId, port,
						maskedMobile, amount, totalTime);

				return TxnStatus.SUCCESS;
			}

			log.warn("ATOM_TOPUP_FAILED txId={} port={} mobile={} amount={} totalDurationMs={}", txnId, port,
					maskedMobile, amount, totalTime);

			return TxnStatus.FAILED;

		} catch (Exception e) {

			long totalTime = System.currentTimeMillis() - startTime;

			log.error("ATOM_TOPUP_ERROR txId={} port={} mobile={} durationMs={} errorType={}", txnId, port,
					maskedMobile, totalTime, e.getClass().getSimpleName(), e);

			return TxnStatus.FAILED;
		}
	}
	
	/**
	@Override
	public TxnStatus topup(Long txnId, String port, String mobile, String amount) {

		long startTime = System.currentTimeMillis();
		String maskedMobile = mask(mobile);

		try {
			Message response;

			// STEP 1: Initial request
			String step1 = "*555*" + mobile + "*9#";
			log.info("txId={} event=STEP1_REQUEST port={} mobile={}", txnId, port, maskedMobile);

			long t1 = System.currentTimeMillis();
			response = client.call(config.getEndpoints().getUssdGateway(), port, step1);
			long d1 = System.currentTimeMillis() - t1;

			log.info("txId={} event=STEP1_RESPONSE port={} mobile={} durationMs={} resp={}", txnId, port, maskedMobile,
					d1, safeResp(response));

			if (response == null || response.getResp() == null) {
				log.error("txId={} event=STEP1_FAILED port={} mobile={} reason=NULL_RESPONSE", txnId, port,
						maskedMobile);
				return TxnStatus.FAILED;
			}

			// STEP 2: Amount input (if needed)
			if (hasText(response, "amount")) {
				log.info("txId={} event=STEP2_REQUEST port={} mobile={} amount={}", txnId, port, maskedMobile, amount);

				long t2 = System.currentTimeMillis();
				response = client.call(config.getEndpoints().getUssdGateway(), port, amount);
				long d2 = System.currentTimeMillis() - t2;

				log.info("txId={} event=STEP2_RESPONSE port={} mobile={} durationMs={} resp={}", txnId, port,
						maskedMobile, d2, safeResp(response));
			}

			// STEP 3: M-PIN flow
			if (hasText(response, "m-pin")) {
				log.info("txId={} event=STEP3_REQUEST port={} mobile={}", txnId, port, maskedMobile);

				long t3 = System.currentTimeMillis();
				response = client.call(config.getEndpoints().getUssdGateway(), port, "2222");
				long d3 = System.currentTimeMillis() - t3;

				log.info("txId={} event=STEP3_RESPONSE port={} mobile={} durationMs={} resp={}", txnId, port,
						maskedMobile, d3, safeResp(response));

				// Sometimes requires second confirm
				if (hasText(response, "m-pin")) {
					log.info("txId={} event=STEP3_RETRY port={} mobile={}", txnId, port, maskedMobile);

					long t4 = System.currentTimeMillis();
					response = client.call(config.getEndpoints().getUssdGateway(), port, "2222");
					long d4 = System.currentTimeMillis() - t4;

					log.info("txId={} event=STEP3_RETRY_RESPONSE port={} mobile={} durationMs={} resp={}", txnId, port,
							maskedMobile, d4, safeResp(response));
				}
			}

			// FINAL
			long totalTime = System.currentTimeMillis() - startTime;

			if (isSuccess(response)) {
				log.info("txId={} event=TOPUP_SUCCESS port={} mobile={} amount={} durationMs={} resp={}", txnId, port,
						maskedMobile, amount, totalTime, safeResp(response));
				return TxnStatus.SUCCESS;
			} else {
				log.error("txId={} event=TOPUP_FAILED port={} mobile={} amount={} durationMs={} resp={}", txnId, port,
						maskedMobile, amount, totalTime, safeResp(response));
				return TxnStatus.FAILED;
			}

		} catch (Exception e) {
			log.error("txId={} event=TOPUP_ERROR port={} mobile={} errorType={} error={}", txnId, port, maskedMobile,
					e.getClass().getSimpleName(), e.getMessage(), e);
			return TxnStatus.FAILED;
		}
	} */

	// ✅ Safe response
	private String safeResp(Message msg) {
		return (msg != null && msg.getResp() != null) ? msg.getResp() : "NULL";
	}

	// ✅ Mask mobile
	private String mask(String mobile) {
		if (mobile == null || mobile.length() < 4)
			return "****";
		return "****" + mobile.substring(mobile.length() - 4);
	}

	// ✅ Case-insensitive match
	private boolean hasText(Message msg, String keyword) {
		return safeResp(msg).toLowerCase().contains(keyword.toLowerCase());
	}

	private boolean isSuccess(Message msg) {
		String resp = safeResp(msg).toLowerCase();
		return !(resp.contains("fail") || resp.contains("error"));
	}
}
