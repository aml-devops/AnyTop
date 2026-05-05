import 'package:flutter/material.dart';

import '../../data/models/operator_model.dart';
import '../../data/models/operator_ui_config.dart';
import '../constants/app_colors.dart';

/// Operator card widget with hover animation.
/// Extracted from dashboard_view.dart.
class OperatorCard extends StatefulWidget {
  final OperatorModel operator;
  final VoidCallback onTap;

  const OperatorCard({super.key, required this.operator, required this.onTap});

  @override
  State<OperatorCard> createState() => _OperatorCardState();
}

class _OperatorCardState extends State<OperatorCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final uiConfig = OperatorUiConfig.forOperator(widget.operator.name);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          offset: _isHovered ? const Offset(0, -0.02) : Offset.zero,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isHovered ? AppColors.slate300 : AppColors.slate200,
                width: 1,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [
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
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: uiConfig.iconColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    uiConfig.icon,
                    color: uiConfig.iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 18),

                Text(
                  widget.operator.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  widget.operator.formattedBalance,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
