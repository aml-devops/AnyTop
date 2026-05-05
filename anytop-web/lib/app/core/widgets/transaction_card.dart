import 'package:flutter/material.dart';

import '../../data/models/operator_model.dart';
import '../constants/app_colors.dart';
import 'status_badge.dart';

/// Mobile transaction card list.
/// Extracted from topup_history_view.dart.
class TransactionCardList extends StatelessWidget {
  final List<TopupTransaction> transactions;

  const TransactionCardList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return _emptyState();
    }

    return Column(
      children: transactions.map((txn) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.slate200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: operator + status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        txn.operatorName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        txn.cardName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.slate400,
                        ),
                      ),
                    ],
                  ),
                  StatusBadge(status: txn.status),
                ],
              ),
              const SizedBox(height: 10),
              // Phone + amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: AppColors.slate400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        txn.phoneNumber,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.slate500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    txn.formattedAmount,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Date + ID
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    txn.formattedDate,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.slate400,
                    ),
                  ),
                  Text(
                    txn.id,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.slate300,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: AppColors.slate300,
            ),
            const SizedBox(height: 12),
            const Text(
              'No transactions found',
              style: TextStyle(
                color: AppColors.slate400,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
