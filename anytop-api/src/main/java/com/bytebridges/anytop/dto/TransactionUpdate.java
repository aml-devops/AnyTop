package com.bytebridges.anytop.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class TransactionUpdate {

    private Long txnId;
    private String status;
    private String simName;
    private String message;
}
