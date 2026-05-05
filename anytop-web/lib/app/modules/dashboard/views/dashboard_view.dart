import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/operator_card.dart';
import '../../../core/widgets/page_header.dart';
import '../../home/controllers/home_controller.dart';

class DashboardView extends GetView<HomeController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppDimensions.mobileBreakpoint;

    return SingleChildScrollView(
      padding: EdgeInsets.all(
          isMobile ? AppDimensions.paddingMobile : AppDimensions.paddingDesktop),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Dashboard',
            subtitle: 'Select an operator to manage top-ups',
            isMobile: isMobile,
          ),
          const SizedBox(height: AppDimensions.spacingSection),

          Obx(() {
            if (controller.isLoading.value) {
              return const AppLoadingIndicator();
            }

            if (controller.errorMessage.value != null) {
              return AppErrorState(
                message: controller.errorMessage.value!,
                onRetry: () => controller.fetchOperators(),
              );
            }

            final operators = controller.operators;

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                int crossAxisCount;
                if (width > 900) {
                  crossAxisCount = 3;
                } else if (width > 500) {
                  crossAxisCount = 2;
                } else {
                  crossAxisCount = 1;
                }
                final spacing = isMobile ? 12.0 : 16.0;
                final cardWidth =
                    (width - (crossAxisCount - 1) * spacing) / crossAxisCount;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: operators.map((op) {
                    return SizedBox(
                      width:
                          crossAxisCount == 1 ? width : cardWidth.clamp(0, 400),
                      child: OperatorCard(
                        operator: op,
                        onTap: () => controller.selectOperator(op.name),
                      ),
                    );
                  }).toList(),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
