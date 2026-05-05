import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/sidebar.dart';
import '../controllers/home_controller.dart';
import '../../dashboard/views/dashboard_view.dart';
import '../../operator_detail/views/operator_detail_view.dart';
import '../../topup_history/views/topup_history_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < AppDimensions.mobileBreakpoint;
        final isTablet =
            constraints.maxWidth >= AppDimensions.mobileBreakpoint &&
            constraints.maxWidth < AppDimensions.tabletBreakpoint;

        return Scaffold(
          key: controller.scaffoldKey,
          backgroundColor: AppColors.scaffoldBg,
          drawer: isMobile
              ? Drawer(
                  width: AppDimensions.sidebarWidth,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: const Sidebar(),
                )
              : null,
          body: Row(
            children: [
              if (!isMobile)
                Sidebar(
                  width: isTablet
                      ? AppDimensions.sidebarTabletWidth
                      : AppDimensions.sidebarWidth,
                ),

              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Obx(() {
                        if (controller.selectedNavIndex.value == 1) {
                          return const TopupHistoryView();
                        }
                        if (controller.selectedOperator.value != null) {
                          return OperatorDetailView(
                            operatorName: controller.selectedOperator.value!,
                          );
                        }
                        return const DashboardView();
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
