package com.bytebridges.anytop.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.bytebridges.anytop.entity.Transaction;

public interface TransactionRepository extends JpaRepository<Transaction, Long> {
}
