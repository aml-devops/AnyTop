import 'package:get/get.dart';

import '../../../data/repositories/operator_repository.dart';
import '../../../data/repositories/topup_repository.dart';
import '../controllers/operator_detail_controller.dart';

class OperatorDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OperatorDetailController>(
      () => OperatorDetailController(
        Get.find<OperatorRepository>(),
        Get.find<TopupRepository>(),
      ),
    );
  }
}

