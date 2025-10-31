import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../modules/home/controllers/home_controller.dart';
import '../modules/home/models/MessageModel.dart';

class FirebaseManager {
  static final FirebaseManager _singleton = FirebaseManager._internal();
  final database = FirebaseDatabase.instance.ref();
  late DatabaseReference rootPath;
  final storage = GetStorage();

  factory FirebaseManager() {
    return _singleton;
  }

  String lastTimeStamp = "";
  HomeController? home;
  String? _currentKey;

  // Getter để lấy key hiện tại
  String? get currentKey => _currentKey ?? storage.read('firebase_key');

  // Setter để cập nhật key và storage
  set currentKey(String? key) {
    _currentKey = key;
    if (key != null && key.isNotEmpty) {
      storage.write('firebase_key', key);
      _updateRootPath();
    } else {
      storage.remove('firebase_key');
      rootPath = database.child('CCCDAPP');
    }
  }

  void _updateRootPath() {
    if (_currentKey != null && _currentKey!.isNotEmpty) {
      rootPath = database.child('CCCDAPP').child(_currentKey!);
    } else {
      rootPath = database.child('CCCDAPP');
    }
  }

  void setUp() {
    // Khôi phục key từ storage
    _currentKey = storage.read('firebase_key');
    _updateRootPath();

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
          home = Get.find<HomeController>();
          home?.onListenNotification(message);
        }
      } catch (e) {
        Get.snackbar("Thông báo", "$e firebase|setup ",
            duration: const Duration(milliseconds: 500));
      }
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
    rootPath.child('cccdauto').set(isAuto);
  }

  // Phương thức để đặt lại connection khi key thay đổi
  void resetConnection() {
    lastTimeStamp = "";
    setUp();
  }

  // Phương thức để kiểm tra xem có key hay không
  bool hasKey() {
    return currentKey != null && currentKey!.isNotEmpty;
  }
}
