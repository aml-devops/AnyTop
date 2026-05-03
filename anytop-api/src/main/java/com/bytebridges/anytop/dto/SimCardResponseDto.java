package com.bytebridges.anytop.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class SimCardResponseDto {

    private Long id;
    private String operator;
    private String simName;
    private Boolean isActive;
    private Integer balance;
}