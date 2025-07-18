import 'package:get/get.dart';

import '../controllers/cccd_error_controller.dart';

class CccdErrorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CccdErrorController>(
      () => CccdErrorController(),
    );
  }
}
