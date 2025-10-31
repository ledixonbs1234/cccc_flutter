import 'package:get/get.dart';

import '../controllers/tim_kiem_controller.dart';

class TimKiemBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TimKiemController>(
      () => TimKiemController(),
    );
  }
}
