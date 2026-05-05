import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Selectable amount chip with hover and selection states.
/// Extracted from operator_detail_view.dart.
class AmountChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const AmountChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<AmountChip> createState() => _AmountChipState();
}

class _AmountChipState extends State<AmountChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.slate900
                : _isHovered
                    ? AppColors.slate200
                    : AppColors.slate100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.slate900
                  : _isHovered
                      ? AppColors.slate300
                      : AppColors.slate200,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.slate900.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color:
                  widget.isSelected ? Colors.white : AppColors.slate700,
            ),
          ),
        ),
      ),
    );
  }
}
