package com.bytebridges.anytop.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import com.bytebridges.anytop.entity.Transaction;
import com.bytebridges.anytop.service.MptTopupService;

@RestController
@RequestMapping("/api/mpt")
@RequiredArgsConstructor
public class MptController {

    private final MptTopupService mptTopupService;

    /**
     * 🚀 Create topup request (ASYNC)
     * - Saves transaction as PENDING
     * - Sends message to RabbitMQ
     * - Returns immediately
     */
    @PostMapping("/topup")
    public Transaction createTopup(
            @RequestParam String phone,
            @RequestParam Integer amount
    ) {

        return mptTopupService.createTopup(phone, amount);
    }

    /**
     * 📊 Check transaction status
     * - Useful because processing is async
     */
    @GetMapping("/transaction/{id}")
    public Transaction getTransaction(@PathVariable Long id) {

        return mptTopupService.getTransactionById(id);
    }
}