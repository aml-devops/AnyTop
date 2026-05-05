import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/operator_model.dart';
import '../../../data/repositories/operator_repository.dart';
import '../../../data/repositories/topup_repository.dart';
import '../../home/controllers/home_controller.dart';

class OperatorDetailController extends GetxController {
  final OperatorRepository _operatorRepo;
  final TopupRepository _topupRepo;

  OperatorDetailController(this._operatorRepo, this._topupRepo);

  final phoneNumber = ''.obs;
  final isLoading = false.obs;
  final selectedAmount = 0.obs;
  final selectedTabIndex = 0.obs;

  final cardActiveStates = <String, bool>{}.obs;

  final isOperatorLoading = false.obs;

  final formKey = GlobalKey<FormState>();

  final phoneController = TextEditingController();

  OperatorModel? currentOperator;

  @override
  void onInit() {
    super.onInit();
    phoneController.addListener(() {
      phoneNumber.value = phoneController.text;
    });
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  Future<void> setOperator(String name) async {
    isOperatorLoading.value = true;

    final response = await _operatorRepo.getOperator(name);
    if (response.success && response.data != null) {
      currentOperator = response.data;

      for (final card in currentOperator!.eLoadCards) {
        if (!cardActiveStates.containsKey(card.name)) {
          cardActiveStates[card.name] = card.isActive;
        }
      }
    }
    print(response.statusCode);
    print(response.message);

    isOperatorLoading.value = false;
  }

  Future<void> toggleCardActive(String cardName) async {
    final currentState = cardActiveStates[cardName];
    if (currentState == null) return;

    final newState = !currentState;
    
    cardActiveStates[cardName] = newState;

    final card = currentOperator?.eLoadCards.firstWhere(
      (c) => c.name == cardName,
      orElse: () => currentOperator!.eLoadCards.first,
    );

    final response = await _operatorRepo.toggleCard(card?.id ?? 0, newState);
    if (!response.success) {
      cardActiveStates[cardName] = currentState;
      Get.snackbar(
        'Error',
        response.message ?? 'Failed to toggle card',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFEE2E2),
        colorText: const Color(0xFFDC2626),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  bool isCardActive(String cardName) {
    return cardActiveStates[cardName] ?? true;
  }

  void selectTab(int index) {
    selectedTabIndex.value = index;
  }

  void selectAmount(int amount) {
    selectedAmount.value = amount;
  }

  Future<void> submitTopup() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedAmount.value == 0) {
      Get.snackbar(
        'Selection Required',
        'Please select a top-up amount.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFEE2E2),
        colorText: const Color(0xFFDC2626),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    isLoading.value = true;

    final request = TopupRequest(
      phoneNumber: phoneNumber.value,
      amount: selectedAmount.value,
      operatorName: currentOperator?.name ?? '',
      cardName: currentOperator?.eLoadCards.isNotEmpty == true
          ? currentOperator!.eLoadCards.first.name
          : '',
    );

    final response = await _topupRepo.submitTopup(request);

    isLoading.value = false;

    if (response.success) {
      Get.snackbar(
        'Top-Up Successful!',
        'Sent ${selectedAmount.value} MMK to ${phoneNumber.value}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDCFCE7),
        colorText: const Color(0xFF16A34A),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.check_circle, color: Color(0xFF16A34A)),
      );

      phoneController.clear();
      selectedAmount.value = 0;

      if (currentOperator != null) {
        try {
          final homeController = Get.find<HomeController>();
          homeController.fetchOperators();
        } catch (_) {}
      }
    } else {
      Get.snackbar(
        'Top-Up Failed',
        response.message ?? 'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFEE2E2),
        colorText: const Color(0xFFDC2626),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline, color: Color(0xFFDC2626)),
      );
    }
  }
}
