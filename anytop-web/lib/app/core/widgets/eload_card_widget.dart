import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/operator_model.dart';
import '../../modules/operator_detail/controllers/operator_detail_controller.dart';
import '../constants/app_colors.dart';

/// E-Load card widget with toggle switch and hover effects.
/// Extracted from operator_detail_view.dart.
class ELoadCardWidget extends StatefulWidget {
  final ELoadCard card;
  final OperatorDetailController controller;
  final bool showOperatorLabel;

  const ELoadCardWidget({
    super.key,
    required this.card,
    required this.controller,
    this.showOperatorLabel = false,
  });

  @override
  State<ELoadCardWidget> createState() => _ELoadCardWidgetState();
}

class _ELoadCardWidgetState extends State<ELoadCardWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Obx(() {
        final isActive = widget.controller.isCardActive(widget.card.name);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? AppColors.slate300 : AppColors.slate200,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
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
              // Operator label badge (for All Operators view)
              if (widget.showOperatorLabel &&
                  widget.card.operatorName.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.slate100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.card.operatorName,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              // Top row — card name + toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      widget.card.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? AppColors.slate900
                            : AppColors.slate400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Working toggle switch
                  SizedBox(
                    height: 28,
                    child: FittedBox(
                      child: Switch(
                        value: isActive,
                        onChanged: (_) => widget.controller.toggleCardActive(
                          widget.card.name,
                        ),
                        activeThumbColor: Colors.white,
                        activeTrackColor: AppColors.slate900,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: AppColors.slate300,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Balance
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: isActive ? AppColors.slate900 : AppColors.slate300,
                  fontFamily: 'Inter',
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(widget.card.formattedBalance),
                    const SizedBox(width: 6),
                    Text(
                      'MMK',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isActive
                            ? AppColors.slate500
                            : AppColors.slate300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
