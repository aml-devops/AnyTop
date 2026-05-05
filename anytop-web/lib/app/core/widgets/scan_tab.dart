import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// QR code scan tab placeholder.
/// Extracted from operator_detail_view.dart.
class ScanTab extends StatelessWidget {
  const ScanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                size: 32,
                color: AppColors.slate400,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Scan QR Code',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.slate700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Scan a topup voucher QR code',
              style: TextStyle(fontSize: 13, color: AppColors.slate400),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Implement scanner
              },
              icon: const Icon(Icons.camera_alt_outlined, size: 18),
              label: const Text('Open Scanner'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.slate900,
                side: const BorderSide(color: AppColors.slate200),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
