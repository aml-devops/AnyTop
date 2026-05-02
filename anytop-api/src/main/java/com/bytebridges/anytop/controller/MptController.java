package com.bytebridges.anytop.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import com.bytebridges.anytop.dto.TopupRequest;
import com.bytebridges.anytop.dto.TopupResponseDto;
import com.bytebridges.anytop.entity.Transaction;
import com.bytebridges.anytop.service.EloadTopupService;

@RestController
@RequestMapping("/api/eload")
@RequiredArgsConstructor
public class MptController {

	private final EloadTopupService eloadTopupService;

	/**
	 * 🚀 Create topup request (ASYNC) - Saves transaction as PENDING - Sends
	 * message to RabbitMQ - Returns immediately
	 */
	@PostMapping("/topup")
	public TopupResponseDto createTopup(@RequestBody TopupRequest request) {

		return eloadTopupService.createTopup(request.getOperator(), request.getPhone(), request.getAmount());
	}

	/**
	 * 📊 Check transaction status - Useful because processing is async
	 */
	@GetMapping("/txns/{id}")
	public Transaction getTransaction(@PathVariable Long id) {

		return eloadTopupService.getTransactionById(id);
	}
}