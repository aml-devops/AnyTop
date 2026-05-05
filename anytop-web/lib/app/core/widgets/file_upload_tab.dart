import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// File upload tab placeholder.
/// Extracted from operator_detail_view.dart.
class FileUploadTab extends StatelessWidget {
  const FileUploadTab({super.key});

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
                Icons.upload_file_outlined,
                size: 32,
                color: AppColors.slate400,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Upload a CSV or Excel file',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.slate700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Bulk topup from a spreadsheet',
              style: TextStyle(fontSize: 13, color: AppColors.slate400),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Implement file upload
              },
              icon: const Icon(Icons.cloud_upload_outlined, size: 18),
              label: const Text('Choose File'),
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
