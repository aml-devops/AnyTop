import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../modules/home/controllers/home_controller.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import 'nav_item.dart';

/// Sidebar widget containing logo, navigation items, and footer.
/// Used as permanent sidebar on desktop/tablet and as Drawer on mobile.
/// Extracted from home_view.dart.
class Sidebar extends StatelessWidget {
  final double width;

  const Sidebar({
    super.key,
    this.width = AppDimensions.sidebarWidth,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Container(
      width: width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.sidebarStart, AppColors.sidebarEnd],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Logo ──
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 36),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.blue500, AppColors.indigo500],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blue500.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'B',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'ByteBridges',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),

            // ── Navigation Items ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  Obx(
                    () => NavItem(
                      icon: Icons.dashboard_outlined,
                      selectedIcon: Icons.dashboard_rounded,
                      label: 'Dashboard',
                      isSelected: controller.selectedNavIndex.value == 0,
                      onTap: () => controller.navigateToDashboard(),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => NavItem(
                      icon: Icons.history_outlined,
                      selectedIcon: Icons.history_rounded,
                      label: 'Topup History',
                      isSelected: controller.selectedNavIndex.value == 1,
                      onTap: () => controller.navigateToHistory(),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ── Footer ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    color: Colors.white.withValues(alpha: 0.08),
                    height: 1,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '© 2026 ByteBridges',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
