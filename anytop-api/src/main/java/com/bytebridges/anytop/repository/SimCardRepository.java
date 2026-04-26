package com.bytebridges.anytop.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.bytebridges.anytop.entity.SimCard;

public interface SimCardRepository extends JpaRepository<SimCard, Long> {

	// 🔐 atomic lock
	@Modifying
	@Query("""
			    UPDATE SimCard s
			    SET s.status = 'BUSY'
			    WHERE s.id = :id
			    AND s.status = 'FREE'
			    AND s.isActive = true
			""")
	int lockSim(@Param("id") Long id);

	@Query("""
			SELECT s FROM SimCard s
			WHERE s.operator = :operator
			AND s.status = 'FREE'
			AND s.isActive = true
			AND (s.balance - s.reservedBalance) >= :amount + :threshold
			ORDER BY s.lastUsedAt ASC
			""")
	List<SimCard> findEligibleSims(String operator, long amount, long threshold);

	@Query("""
			SELECT s FROM SimCard s
			WHERE s.isActive = true
			AND s.status != 'DOWN'
			""")
	List<SimCard> findAllActiveSims();
}