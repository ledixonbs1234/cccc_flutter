import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/managers/fireabaseManager.dart';
import 'app/modules/home/controllers/home_controller.dart';
import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // AwesomeNotifications().initialize(
  //     // set the icon to null if you want to use the default app icon
  //     null,
  //     // [
  //     //   NotificationChannel(
  //     //       channelGroupKey: 'basic_channel_group',
  //     //       channelKey: 'test',
  //     //       channelName: 'Basic notifications',
  //     //       channelDescription: 'Notification channel for basic tests',
  //     //       defaultColor: const Color(0xFF9D50DD),
  //     //       ledColor: Colors.white)
  //     // ],
  //     // Channel groups are only visual and are not required

  //     debug: true);
  // await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseManager().setUp();

  Get.put(HomeController());
  // Get.put(MaHieuController());
  // Get.put(DetailController());
  // Get.put(DingoaiController());
  // Get.put(WebController());
  // Get.put(SavedMHController());
  // Get.put(AutoBdController());

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
