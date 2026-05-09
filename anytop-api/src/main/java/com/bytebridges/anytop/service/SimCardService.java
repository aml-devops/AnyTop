package com.bytebridges.anytop.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.bytebridges.anytop.common.ServiceResponse;
import com.bytebridges.anytop.dto.OperatorBalanceDto;
import com.bytebridges.anytop.dto.OperatorBalanceResponseDto;
import com.bytebridges.anytop.dto.SimCardResponseDto;
import com.bytebridges.anytop.entity.SimCard;
import com.bytebridges.anytop.projection.SimCardProjection;
import com.bytebridges.anytop.repository.SimCardRepository;
import com.bytebridges.anytop.service.ussd.BalanceCallUssdService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class SimCardService {

	private final SimCardRepository simCardRepository;
	private final BalanceCallUssdService balanceCallUssdService;

	public ServiceResponse<?> getOperatorBalances() {

		try {

			List<Object[]> results = simCardRepository.getOperatorBalances();

			List<OperatorBalanceDto> operators = results.stream()
					.map(row -> new OperatorBalanceDto((String) row[0], (Long) row[1])).toList();

			Long grandTotal = simCardRepository.getGrandTotalBalance();

			OperatorBalanceResponseDto response = new OperatorBalanceResponseDto(operators, grandTotal);

			log.info("Operator balances fetched successfully | operators={}", operators.size());

			return ServiceResponse.success(response, "Operator balances fetched successfully");

		} catch (Exception e) {

			log.error("Failed to fetch operator balances", e);

			return ServiceResponse.error(500, "Failed to fetch operator balances");
		}
	}

	public ServiceResponse<?> getSimCardsByOperator(String operator) {

		try {

			List<SimCardProjection> results = simCardRepository.findSimCardsByOperator(operator);

			List<SimCardResponseDto> response = results.stream().map(r -> new SimCardResponseDto(r.getId(),
					r.getOperator(), r.getSimName(), r.getIsActive(), r.getBalance())).toList();

			log.info("SIM cards fetched operator={} count={}", operator, response.size());

			return ServiceResponse.success(response, "SIM cards fetched successfully");

		} catch (Exception e) {

			log.error("Failed to fetch SIM cards operator={}", operator, e);

			return ServiceResponse.error(500, "Failed to fetch SIM cards");
		}
	}

	public ServiceResponse<?> getSimCards() {

		try {

			List<SimCardProjection> results = simCardRepository.findSimCards();

			List<SimCardResponseDto> response = results.stream().map(r -> new SimCardResponseDto(r.getId(),
					r.getOperator(), r.getSimName(), r.getIsActive(), r.getBalance())).toList();

			log.info("SIM cards fetched count={}", response.size());

			return ServiceResponse.success(response, "SIM cards fetched successfully");

		} catch (Exception e) {

			log.error("Failed to fetch SIM operator={}", e);

			return ServiceResponse.error(500, "Failed to fetch SIM cards");
		}
	}

	public ServiceResponse<?> updateSimStatus(Long id, Integer isActive) {

		try {

			if (isActive != 0 && isActive != 1) {
				return ServiceResponse.error(400, "Invalid status value. Use 1 (active) or 0 (inactive)");
			}

			int updatedRows = simCardRepository.updateSimStatus(id, isActive);

			if (updatedRows == 0) {
				return ServiceResponse.error(404, "SIM not found");
			}

			log.info("SIM status updated id={} isActive={}", id, isActive);

			return ServiceResponse.success(true, "SIM status updated successfully");

		} catch (Exception e) {

			log.error("Failed to update SIM status id={}", id, e);

			return ServiceResponse.error(500, "Failed to update SIM status");
		}
	}

	@Transactional
	public void refreshActiveSimBalances() {

		List<SimCard> sims = simCardRepository.findByIsActive(true);

		if (sims.isEmpty()) {

			log.warn("No active SIM cards found");

			return;
		}

		for (SimCard sim : sims) {

			try {
				
				log.info("SIM balance request operator={} port={}", sim.getOperator(), sim.getSimName());
				Integer balance = getBalance(sim.getOperator(), sim.getSimName());

				sim.setBalance(balance);

				simCardRepository.save(sim);

				log.info("SIM balance updated simId={} operator={} port={} balance={}", sim.getId(),
						sim.getOperator(), sim.getSimName(), balance);

			} catch (Exception e) {

				log.error("SIM balance update failed simId={} operator={} port={} reason={}", sim.getId(),
						sim.getOperator(), sim.getSimName(), e.getMessage(), e);

			} finally {

				try {

					Thread.sleep(2000);

				} catch (InterruptedException e) {

					Thread.currentThread().interrupt();

					log.warn("SIM balance scheduler interrupted");
				}
			}
		}
	}

	public Integer getBalance(String operator, String sameName) {

		return switch (operator.toUpperCase()) {

		case "MPT" -> balanceCallUssdService.getMPTBalance(sameName);

		case "ATOM" -> balanceCallUssdService.getAtomBalance(sameName);

		case "U9" -> balanceCallUssdService.getU9Balance(sameName);

		case "MYTEL" -> balanceCallUssdService.getMytelBalance(sameName);

		default -> 0;
		};
	}
}
