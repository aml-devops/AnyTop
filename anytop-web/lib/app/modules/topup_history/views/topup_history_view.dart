import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/history_filters.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/widgets/transaction_card.dart';
import '../../../core/widgets/transaction_table.dart';
import '../controllers/topup_history_controller.dart';

class TopupHistoryView extends GetView<TopupHistoryController> {
  const TopupHistoryView({super.key});

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
            title: 'Topup History',
            subtitle: 'View all past topup transactions',
            isMobile: isMobile,
          ),
          const SizedBox(height: 24),

          HistoryFilters(controller: controller, isMobile: isMobile),
          const SizedBox(height: 20),

          Obx(() {
            if (controller.isLoading.value) {
              return const AppLoadingIndicator();
            }

            if (controller.errorMessage.value != null) {
              return AppErrorState(
                message: controller.errorMessage.value!,
                onRetry: () => controller.fetchTransactions(),
              );
            }

            final txns = controller.filteredTransactions;
            if (isMobile) {
              return TransactionCardList(transactions: txns);
            }
            return TransactionTable(transactions: txns);
          }),
        ],
      ),
    );
  }
}
