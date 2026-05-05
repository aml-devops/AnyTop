import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Tab bar for switching between Manual, File, and Scan topup modes.
/// Extracted from operator_detail_view.dart.
class TopupTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const TopupTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  static const _tabs = [
    {'icon': Icons.keyboard_outlined, 'label': 'Manual'},
    {'icon': Icons.upload_file_outlined, 'label': 'File'},
    {'icon': Icons.sync_rounded, 'label': 'Scan'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.slate100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: _tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = selectedIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(index),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tab['icon'] as IconData,
                        size: 16,
                        color: isSelected
                            ? AppColors.slate900
                            : AppColors.slate400,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tab['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? AppColors.slate900
                              : AppColors.slate400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
