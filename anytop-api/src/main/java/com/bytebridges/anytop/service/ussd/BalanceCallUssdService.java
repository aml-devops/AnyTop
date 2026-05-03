package com.bytebridges.anytop.service.ussd;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.springframework.stereotype.Service;

import com.bytebridges.anytop.config.EloadConfig;
import com.bytebridges.anytop.dto.Message;
import com.bytebridges.anytop.service.external.UssdGatewayClient;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RequiredArgsConstructor
@Slf4j
@Service
public class BalanceCallUssdService {

	private final UssdGatewayClient client;
	private final EloadConfig config;
	
	//String response = "05-03 17:00:54 09421251159 Your main balance is 503 Ks, valid until 02/04/2027.Detail in MPT4U(*4040#). Dial *5555# for 100% Cashback.";
	public Integer getBalance(String port) {

		int balance = 0;
		String balUssd = "*124#";

		Message pre = client.call(config.getEndpoints().getUssdGateway(), port, balUssd);

		if (pre == null || pre.getResp() == null) {

			log.warn("Balance inquiry failed | port={} | reason=NULL_RESPONSE", port);

			return balance;
		}

		String response = pre.getResp();

		Pattern pattern = Pattern.compile("balance is\\s+([\\d,]+)\\s+Ks", Pattern.CASE_INSENSITIVE);

		Matcher matcher = pattern.matcher(response);

		if (matcher.find()) {

			String balanceText = matcher.group(1).replace(",", "");

			balance = Integer.parseInt(balanceText);

			log.debug("Balance inquiry success | port={} | balance={} Ks", port, balance);

		} else {

			log.warn("Balance parsing failed | port={} | response={}", port, response);
		}

		return balance;
	}

}
