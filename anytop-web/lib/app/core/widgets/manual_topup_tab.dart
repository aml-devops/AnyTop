import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/operator_model.dart';
import '../../modules/operator_detail/controllers/operator_detail_controller.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'amount_chip.dart';

/// Manual topup tab with phone number input and amount selection.
/// Extracted from operator_detail_view.dart.
class ManualTopupTab extends StatelessWidget {
  final OperatorDetailController controller;
  final OperatorModel operator;
  final bool isMobile;

  const ManualTopupTab({
    super.key,
    required this.controller,
    required this.operator,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phone Number label
          const Text('Phone Number', style: AppTextStyles.formLabel),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller.phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(fontSize: 15, color: AppColors.slate900),
            decoration: InputDecoration(
              hintText: 'e.g. 09500012345',
              hintStyle: const TextStyle(
                color: AppColors.slate300,
                fontSize: 15,
              ),
              filled: true,
              fillColor: AppColors.slate50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
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
                borderSide: const BorderSide(
                  color: AppColors.blue500,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.error,
                  width: 1.5,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Amount (MMK)
          const Text('Amount (MMK)', style: AppTextStyles.formLabel),
          const SizedBox(height: 10),
          Obx(
            () => Wrap(
              spacing: isMobile ? 8 : 10,
              runSpacing: isMobile ? 8 : 10,
              children: [
                ...operator.topUpAmounts.map((amount) {
                  final isSelected = controller.selectedAmount.value == amount;
                  return AmountChip(
                    label: _formatNumber(amount),
                    isSelected: isSelected,
                    onTap: () => controller.selectAmount(amount),
                  );
                }),
                // "Other" text field
                SizedBox(
                  width: 100,
                  height: 42,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Other',
                      hintStyle: const TextStyle(
                        color: AppColors.slate300,
                        fontSize: 14,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: AppColors.slate50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.slate200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.slate200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.blue500,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed != null && parsed > 0) {
                        controller.selectAmount(parsed);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Send Topup Button ──
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.submitTopup(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.slate900,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.slate900.withValues(alpha: 0.7),
                  disabledForegroundColor:
                      Colors.white.withValues(alpha: 0.7),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Send Topup',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
