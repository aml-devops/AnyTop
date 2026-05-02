package com.bytebridges.anytop.service.router;

import java.util.Map;

import org.springframework.stereotype.Service;

import com.bytebridges.anytop.enums.Operator;
import com.bytebridges.anytop.enums.TxnStatus;
import com.bytebridges.anytop.service.UssdTopupService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UssdTopupEngine {

    private final Map<String, UssdTopupService> operatorServices;

    public TxnStatus route(Operator operator,
                           Long txnId,
                           String port,
                           String password,
                           String mobile,
                           String amount) {

        UssdTopupService service =
                operatorServices.get(operator.name());

        if (service == null) {
            throw new IllegalArgumentException("Unsupported operator: " + operator);
        }

        return service.topup(txnId, port, password, mobile, amount);
    }
}