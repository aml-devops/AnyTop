package com.bytebridges.anytop.scheduler;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.bytebridges.anytop.service.SimCardService;

@Component
@RequiredArgsConstructor
@Slf4j
public class SimBalanceScheduler {
	
	private final SimCardService simCardService;

	@Scheduled(cron = "0 0 * * * *")
	public void refreshBalances() {

		log.info("SIM balance refresh started");

		simCardService.refreshActiveSimBalances();

		log.info("SIM balance refresh completed");
	}
}
