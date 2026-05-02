package com.bytebridges.anytop.dto;

import lombok.Data;

@Data
public class TopupRequest {
	private String operator;
	private String phone;
	private Integer amount;
}