import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Status badge displaying Success, Pending, or Failed state.
/// Extracted from topup_history_view for reuse.
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case 'Success':
        bgColor = AppColors.successBg;
        textColor = AppColors.success;
        icon = Icons.check_circle_outline;
        break;
      case 'Pending':
        bgColor = AppColors.warningBg;
        textColor = AppColors.warning;
        icon = Icons.access_time;
        break;
      case 'Failed':
        bgColor = AppColors.errorBg;
        textColor = AppColors.error;
        icon = Icons.cancel_outlined;
        break;
      default:
        bgColor = AppColors.slate100;
        textColor = AppColors.slate500;
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
