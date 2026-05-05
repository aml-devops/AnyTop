import 'package:get/get.dart';

import '../../../data/models/operator_model.dart';
import '../../../data/repositories/topup_repository.dart';

class TopupHistoryController extends GetxController {
  final TopupRepository _topupRepo;

  TopupHistoryController(this._topupRepo);

  final transactions = <TopupTransaction>[].obs;

  final isLoading = true.obs;

  final errorMessage = Rxn<String>();

  final searchQuery = ''.obs;
  final selectedOperatorFilter = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    isLoading.value = true;
    errorMessage.value = null;

    final response = await _topupRepo.getTransactions();
    if (response.success && response.data != null) {
      transactions.value = response.data!;
    } else {
      errorMessage.value = response.message ?? 'Failed to load transactions';
    }

    isLoading.value = false;
  }

  Future<void> refresh() => fetchTransactions();

  Future<void> exportTransactions() async {
    final response = await _topupRepo.exportTransactions();
    if (response.success) {
      Get.snackbar(
        'Export Ready',
        response.message ?? 'File exported successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Export Failed',
        response.message ?? 'Failed to export',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  List<TopupTransaction> get filteredTransactions {
    return transactions.where((txn) {
      final matchesSearch = searchQuery.value.isEmpty ||
          txn.phoneNumber.contains(searchQuery.value) ||
          txn.operatorName
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase());
      final matchesOperator = selectedOperatorFilter.value == 'All' ||
          txn.operatorName == selectedOperatorFilter.value;
      return matchesSearch && matchesOperator;
    }).toList();
  }
}
