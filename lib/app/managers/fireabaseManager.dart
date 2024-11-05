import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

import '../modules/home/controllers/home_controller.dart';
import '../modules/home/models/MessageModel.dart';

class FirebaseManager {
  static final FirebaseManager _singleton = FirebaseManager._internal();
  final database = FirebaseDatabase.instance.ref();
  late DatabaseReference rootPath = database.child('CCCDAPP');
  factory FirebaseManager() {
    return _singleton;
  }
  String lastTimeStamp = "";
  HomeController? home;
  void setUp() {
    sendAutoRunToFirebase(false);
    rootPath.child('message/').onValue.listen((event) {
      if (event.snapshot.value == null) return;
      try {
        Map<dynamic, dynamic> value =
            event.snapshot.value as Map<dynamic, dynamic>;

        MessageReceiveModel message = MessageReceiveModel.fromJson(value);
        if (lastTimeStamp == "") {
          lastTimeStamp = message.TimeStamp;
          return;
        }
        if (message.TimeStamp != lastTimeStamp) {
          lastTimeStamp = message.TimeStamp;
          //         GetStorage().write('getLastTimeStamp', lastTimeStamp);
          home = Get.find<HomeController>();
          home?.onListenNotification(message);
        }
      } catch (e) {
        Get.snackbar("Thông báo", "$e firebase|setup ",
            duration: const Duration(milliseconds: 500));
      }
      // }
    });
  }

  // Future<void> addMessageDetail(String lenh, String messageJson) async {
  //   MessageReceiveModel message = MessageReceiveModel(lenh, messageJson);

  //   await rootPath.child('message/topc').set(message.toJson());
  //   if (lenh == "themcode") {
  //     Get.snackbar('test', lenh, duration: Duration(seconds: 1));
  //   }
  // }

  FirebaseManager._internal();

  void sendAutoRunToFirebase(bool isAuto) {
    FirebaseManager().rootPath.child('cccdauto').set(isAuto);
  }
}
