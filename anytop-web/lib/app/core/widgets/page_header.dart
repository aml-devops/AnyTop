import 'package:flutter/material.dart';

import '../constants/app_text_styles.dart';

/// Reusable page header with title + subtitle.
/// Used in dashboard_view, operator_detail_view, and topup_history_view.
class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isMobile;

  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.pageTitle(isMobile: isMobile),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTextStyles.pageSubtitle,
        ),
      ],
    );
  }
}
