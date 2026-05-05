import 'package:get/get.dart';

import '../../../data/providers/operator_provider.dart';
import '../../../data/providers/topup_provider.dart';
import '../../../data/repositories/operator_repository.dart';
import '../../../data/repositories/topup_repository.dart';
import '../../operator_detail/controllers/operator_detail_controller.dart';
import '../../topup_history/controllers/topup_history_controller.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OperatorProvider>(() => OperatorProvider(), fenix: true);
    Get.lazyPut<TopupProvider>(() => TopupProvider(), fenix: true);

    Get.lazyPut<OperatorRepository>(
      () => OperatorRepository(Get.find<OperatorProvider>()),
      fenix: true,
    );
    Get.lazyPut<TopupRepository>(
      () => TopupRepository(Get.find<TopupProvider>()),
      fenix: true,
    );

    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<OperatorRepository>()),
    );
    Get.lazyPut<OperatorDetailController>(
      () => OperatorDetailController(
        Get.find<OperatorRepository>(),
        Get.find<TopupRepository>(),
      ),
      fenix: true,
    );
    Get.lazyPut<TopupHistoryController>(
      () => TopupHistoryController(Get.find<TopupRepository>()),
      fenix: true,
    );
  }
}

