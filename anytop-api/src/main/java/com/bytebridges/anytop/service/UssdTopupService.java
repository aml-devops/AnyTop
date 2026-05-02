package com.bytebridges.anytop.service;

import com.bytebridges.anytop.enums.TxnStatus;

public interface UssdTopupService {
    TxnStatus topup(Long txId, String port, String password, String mobile, String amount);
}
