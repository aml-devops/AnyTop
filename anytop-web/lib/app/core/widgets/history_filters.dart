import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../modules/topup_history/controllers/topup_history_controller.dart';
import '../constants/app_colors.dart';

/// Filter bar for topup history — search, operator dropdown, and export button.
/// Extracted from topup_history_view.dart.
class HistoryFilters extends StatelessWidget {
  final TopupHistoryController controller;
  final bool isMobile;

  const HistoryFilters({
    super.key,
    required this.controller,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return _buildMobileLayout();
    }
    return _buildDesktopLayout();
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Search
        SizedBox(
          height: 42,
          child: TextField(
            onChanged: (val) => controller.searchQuery.value = val,
            style: const TextStyle(fontSize: 14),
            decoration: _searchDecoration(),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: _filterBoxDecoration(),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedOperatorFilter.value,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.slate500,
                        size: 18,
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.slate700,
                      ),
                      items: _dropdownItems(),
                      onChanged: (val) {
                        if (val != null) {
                          controller.selectedOperatorFilter.value = val;
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _exportButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        SizedBox(
          width: 280,
          height: 42,
          child: TextField(
            onChanged: (val) => controller.searchQuery.value = val,
            style: const TextStyle(fontSize: 14),
            decoration: _searchDecoration(),
          ),
        ),
        const SizedBox(width: 12),
        Obx(
          () => Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: _filterBoxDecoration(),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedOperatorFilter.value,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.slate500,
                  size: 18,
                ),
                style: const TextStyle(
                    fontSize: 14, color: AppColors.slate700),
                items: _dropdownItems(),
                onChanged: (val) {
                  if (val != null) {
                    controller.selectedOperatorFilter.value = val;
                  }
                },
              ),
            ),
          ),
        ),
        const Spacer(),
        _exportButton(),
      ],
    );
  }

  InputDecoration _searchDecoration() {
    return InputDecoration(
      hintText: 'Search by phone or operator...',
      hintStyle: const TextStyle(color: AppColors.slate300, fontSize: 14),
      prefixIcon: const Icon(
        Icons.search_rounded,
        size: 18,
        color: AppColors.slate400,
      ),
      filled: true,
      fillColor: AppColors.cardBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.slate200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.slate200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppColors.blue500, width: 1.5),
      ),
    );
  }

  BoxDecoration _filterBoxDecoration() {
    return BoxDecoration(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.slate200),
    );
  }

  List<DropdownMenuItem<String>> _dropdownItems() {
    return [
      'All',
      'MPT',
      'Atom',
      'U9',
      'Mytel',
    ].map((op) => DropdownMenuItem(value: op, child: Text(op))).toList();
  }

  Widget _exportButton() {
    return OutlinedButton.icon(
      onPressed: () {
        // TODO: Implement export
      },
      icon: const Icon(Icons.download_outlined, size: 16),
      label: const Text('Export'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.slate700,
        side: const BorderSide(color: AppColors.slate200),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
