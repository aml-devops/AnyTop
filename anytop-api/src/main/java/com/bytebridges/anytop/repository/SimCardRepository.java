package com.bytebridges.anytop.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import com.bytebridges.anytop.entity.SimCard;
import com.bytebridges.anytop.projection.SimCardProjection;

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

	@Query("""
			 SELECT s.operator, SUM(s.balance)
			 FROM SimCard s
			 GROUP BY s.operator
			""")
	List<Object[]> getOperatorBalances();

	@Query("""
			 SELECT SUM(s.balance)
			 FROM SimCard s
			""")
	Long getGrandTotalBalance();

	@Query(value = """
			SELECT id AS id,
				   operator as operator,
			       sim_name AS simName,
			       is_active AS isActive,
			       balance AS balance
			FROM sim_card
			WHERE operator = :operator
			""", nativeQuery = true)
	List<SimCardProjection> findSimCardsByOperator(String operator);

	@Query(value = """
			SELECT id AS id,
				   operator as operator,
			       sim_name AS simName,
			       is_active AS isActive,
			       balance AS balance
			FROM sim_card
			""", nativeQuery = true)
	List<SimCardProjection> findSimCards();

	@Modifying
	@Transactional
	@Query(value = """
			UPDATE sim_card
			SET is_active = :isActive
			WHERE id = :id
			""", nativeQuery = true)
	int updateSimStatus(Long id, Integer isActive);
	
	List<SimCard> findByIsActive(Boolean isActive);

}