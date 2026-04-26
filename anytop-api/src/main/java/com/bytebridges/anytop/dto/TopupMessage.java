package com.bytebridges.anytop.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class TopupMessage {

    private Long txnId;
    private String operator;
    private String messageId;
}
