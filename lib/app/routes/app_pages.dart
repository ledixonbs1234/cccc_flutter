import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/cccd_error/bindings/cccd_error_binding.dart';
import '../modules/cccd_error/views/cccd_error_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.CCCD_ERROR,
      page: () => const CccdErrorView(),
      binding: CccdErrorBinding(),
    ),
  ];
}
