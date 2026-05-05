import 'package:flutter/material.dart';

import '../../data/models/operator_model.dart';
import '../constants/app_colors.dart';
import 'status_badge.dart';

class TransactionTable extends StatelessWidget {
  final List<TopupTransaction> transactions;

  const TransactionTable({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.slate50,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(bottom: BorderSide(color: AppColors.slate200)),
            ),
            child: const Row(
              children: [
                _TableHeader('ID', flex: 1),
                _TableHeader('Operator', flex: 1),
                _TableHeader('Phone', flex: 2),
                _TableHeader('Amount', flex: 1),
                _TableHeader('Card', flex: 1),
                _TableHeader('Status', flex: 1),
                _TableHeader('Date', flex: 2),
              ],
            ),
          ),

          if (transactions.isEmpty)
            _emptyState()
          else
            ...transactions.asMap().entries.map((entry) {
              final index = entry.key;
              final txn = entry.value;
              return _TableRow(
                txn: txn,
                isLast: index == transactions.length - 1,
              );
            }),
        ],
      ),
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

class _TableHeader extends StatelessWidget {
  final String label;
  final int flex;

  const _TableHeader(this.label, {this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.slate400,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _TableRow extends StatefulWidget {
  final TopupTransaction txn;
  final bool isLast;

  const _TableRow({required this.txn, required this.isLast});

  @override
  State<_TableRow> createState() => _TableRowState();
}

class _TableRowState extends State<_TableRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: _isHovered ? AppColors.slate50 : Colors.white,
          border: !widget.isLast
              ? const Border(bottom: BorderSide(color: AppColors.slate100))
              : null,
          borderRadius: widget.isLast
              ? const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                )
              : null,
        ),
        child: Row(
          children: [
            _cell(
              widget.txn.id,
              1,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.slate300,
                fontWeight: FontWeight.w500,
              ),
            ),
            _cell(
              widget.txn.operatorName,
              1,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.slate900,
              ),
            ),
            _cell(widget.txn.phoneNumber, 2),
            _cell(
              widget.txn.formattedAmount,
              1,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.slate700,
              ),
            ),
            _cell(widget.txn.cardName, 1),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(right: 12.0),
                child: StatusBadge(status: widget.txn.status),
              ),
            ),
            _cell(widget.txn.formattedDate, 2),
          ],
        ),
      ),
    );
  }

  Widget _cell(String text, int flex, {TextStyle? style}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style:
            style ?? const TextStyle(fontSize: 13, color: AppColors.slate500),
      ),
    );
  }
}
