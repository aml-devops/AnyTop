import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Animated back button with hover effect.
/// Extracted from operator_detail_view.dart.
class BackButton extends StatefulWidget {
  final VoidCallback onTap;
  final String label;

  const BackButton({
    super.key,
    required this.onTap,
    this.label = 'Back to Dashboard',
  });

  @override
  State<BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<BackButton> {
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
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.slate200 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_back_rounded,
                size: 16,
                color: _isHovered ? AppColors.slate700 : AppColors.slate500,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  color: _isHovered ? AppColors.slate700 : AppColors.slate500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
