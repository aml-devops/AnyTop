import 'package:get/get.dart';

import '../../../data/repositories/topup_repository.dart';
import '../controllers/topup_history_controller.dart';

class TopupHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TopupHistoryController>(
      () => TopupHistoryController(Get.find<TopupRepository>()),
    );
  }
}
