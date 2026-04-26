package com.bytebridges.anytop.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

import com.bytebridges.anytop.enums.SimStatus;

@Entity
@Table(name = "sim_card")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class SimCard {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String simName;

    private String operator; // MPT, Ooredoo, Mytel

    @Enumerated(EnumType.STRING)
    private SimStatus status; // FREE, BUSY, LOW_BALANCE, DOWN

    private Boolean isActive;

    private Long balance;           // cached balance
    private Long reservedBalance;   // locked amount

    private LocalDateTime lastUsedAt;

    //private LocalDateTime lastSyncedAt;
}