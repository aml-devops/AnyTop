import 'package:flutter/material.dart' hide BackButton;
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/back_button.dart';
import '../../../core/widgets/eload_card_widget.dart';
import '../../../core/widgets/file_upload_tab.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/manual_topup_tab.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/widgets/scan_tab.dart';
import '../../../core/widgets/topup_tab_bar.dart';
import '../../../data/models/operator_model.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/operator_detail_controller.dart';

class OperatorDetailView extends GetView<OperatorDetailController> {
  final String operatorName;

  const OperatorDetailView({super.key, required this.operatorName});

  @override
  Widget build(BuildContext context) {
    controller.setOperator(operatorName);
    final homeController = Get.find<HomeController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppDimensions.mobileBreakpoint;

    return Obx(() {
      if (controller.isOperatorLoading.value ||
          controller.currentOperator == null) {
        return const AppLoadingIndicator();
      }

      final op = controller.currentOperator!;

      return SingleChildScrollView(
        padding: EdgeInsets.all(
          isMobile ? AppDimensions.paddingMobile : AppDimensions.paddingDesktop,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackButton(onTap: () => homeController.backToDashboard()),
            const SizedBox(height: 20),

            PageHeader(
              title: '${op.name} Topup',
              subtitle: 'Manage ${op.name} E-Load cards and topups',
              isMobile: isMobile,
            ),
            const SizedBox(height: AppDimensions.spacingSection),

            const Text('E-LOAD CARDS', style: AppTextStyles.sectionLabel),
            const SizedBox(height: 14),
            _buildELoadCards(controller, op, isMobile),
            const SizedBox(height: AppDimensions.spacingSection),

            _buildTopupSection(controller, op, isMobile),
          ],
        ),
      );
    });
  }

  Widget _buildELoadCards(
    OperatorDetailController controller,
    OperatorModel op,
    bool isMobile,
  ) {
    if (op.eLoadCards.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate200),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.credit_card_off_outlined,
              size: 40,
              color: AppColors.slate300,
            ),
            SizedBox(height: 8),
            Text(
              'No E-Load cards available',
              style: TextStyle(color: AppColors.slate400, fontSize: 14),
            ),
          ],
        ),
      );
    }

    final isAllOperators = op.name == 'All Operators';

    final List<List<ELoadCard>> chunks = [];
    for (var i = 0; i < op.eLoadCards.length; i += 2) {
      chunks.add(op.eLoadCards.sublist(
        i,
        i + 2 > op.eLoadCards.length ? op.eLoadCards.length : i + 2,
      ));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: chunks.map((chunk) {
          final isLastChunk = chunk == chunks.last;
          return Padding(
            padding: EdgeInsets.only(right: isLastChunk ? 0 : 16.0),
            child: SizedBox(
              width: 280,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ELoadCardWidget(
                    card: chunk[0],
                    controller: controller,
                    showOperatorLabel: isAllOperators,
                  ),
                  if (chunk.length > 1) ...[
                    const SizedBox(height: 16),
                    ELoadCardWidget(
                      card: chunk[1],
                      controller: controller,
                      showOperatorLabel: isAllOperators,
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopupSection(
    OperatorDetailController controller,
    OperatorModel op,
    bool isMobile,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TOPUP', style: AppTextStyles.sectionLabel),
            const SizedBox(height: 16),

            Obx(
              () => TopupTabBar(
                selectedIndex: controller.selectedTabIndex.value,
                onTabSelected: controller.selectTab,
              ),
            ),
            const SizedBox(height: 24),

            Obx(() {
              switch (controller.selectedTabIndex.value) {
                case 0:
                  return ManualTopupTab(
                    controller: controller,
                    operator: op,
                    isMobile: isMobile,
                  );
                case 1:
                  return const FileUploadTab();
                case 2:
                  return const ScanTab();
                default:
                  return ManualTopupTab(
                    controller: controller,
                    operator: op,
                    isMobile: isMobile,
                  );
              }
            }),
          ],
        ),
      ),
    );
  }
}
