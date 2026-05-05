import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/operator_model.dart';
import '../../../data/repositories/operator_repository.dart';

class HomeController extends GetxController {
  final OperatorRepository _operatorRepo;

  HomeController(this._operatorRepo);

  final selectedNavIndex = 0.obs;

  final selectedOperator = Rxn<String>();

  final isSidebarOpen = false.obs;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final operators = <OperatorModel>[].obs;

  final isLoading = true.obs;

  final errorMessage = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    fetchOperators();
  }

  Future<void> fetchOperators() async {
    isLoading.value = true;
    errorMessage.value = null;

    final response = await _operatorRepo.getOperators();
    if (response.success && response.data != null) {
      operators.value = response.data!;
    } else {
      errorMessage.value = response.message ?? 'Failed to load operators';
    }

    isLoading.value = false;
  }

  void navigateToDashboard() {
    selectedNavIndex.value = 0;
    selectedOperator.value = null;
    _closeDrawerIfOpen();
  }

  void navigateToHistory() {
    selectedNavIndex.value = 1;
    selectedOperator.value = null;
    _closeDrawerIfOpen();
  }

  void selectOperator(String operatorName) {
    selectedOperator.value = operatorName;
    selectedNavIndex.value = 0;
  }

  void backToDashboard() {
    selectedOperator.value = null;
  }

  void toggleSidebar() {
    isSidebarOpen.value = !isSidebarOpen.value;
  }

  void _closeDrawerIfOpen() {
    if (scaffoldKey.currentState?.isDrawerOpen == true) {
      scaffoldKey.currentState?.closeDrawer();
    }
  }

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }
}
