package com.bytebridges.anytop.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class OperatorBalanceDto {

    private String operator;
    private Long totalBalance;
}
