package com.bytebridges.anytop.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "transaction")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Transaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String phoneNumber;

    private Integer amount;

    private String operator;

    private String status;

    private Long simId;
    
    private String messageId;

    private LocalDateTime createdAt;
}
