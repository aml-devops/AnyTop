import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppLoadingIndicator extends StatelessWidget {
  final double padding;

  const AppLoadingIndicator({super.key, this.padding = 60});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: const CircularProgressIndicator(
          color: AppColors.slate900,
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}
