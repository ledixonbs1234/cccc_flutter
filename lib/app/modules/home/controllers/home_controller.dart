import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/services.dart';

import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'package:get/get.dart';

import '../../../managers/fireabaseManager.dart';
import '../models/MessageModel.dart';
import '../models/cccdInfo.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController

  final count = 0.obs;
  final nameCurrent = "".obs;
  final isRunning = false.obs;
  final totalCCCD = <CCCDInfo>[].obs;
  final indexCurrent = 0.obs;
  final isAutoRun = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  String formatDateString(String inputDate) {
    // Chuyển đổi chuỗi ngày thành đối tượng DateTime

    // Kiểm tra xem chuỗi có đúng độ dài không

    if (inputDate.length != 8) {
      return "Invalid date format";
    }

    // Chia nhỏ chuỗi thành ngày, tháng, năm

    String day = inputDate.substring(0, 2);

    String month = inputDate.substring(2, 4);

    String year = inputDate.substring(4);

    // Tạo chuỗi mới theo định dạng "dd/MM/yyyy"

    String formattedDate = "$day/$month/$year";

    return formattedDate;
  }

  late StreamSubscription<dynamic>? streamCapture = null;
  late StreamSubscription<dynamic>? streamSaveData = null;

  void capture() {
    try {
      List<String> tempBarcode = [];
      if (streamCapture != null) {
        streamCapture!.cancel();
      }

      streamCapture = FlutterBarcodeScanner.getBarcodeStreamReceiver(
              "#ff6666", 'Cancel', true, ScanMode.DEFAULT)
          ?.listen((barcode) async {
        String barcodeFilled = barcode.trim().toString().toUpperCase();

//052093000573|215277482|Lê Đi Xơn|08071993|Nam|Tổ 2, Khu phố Phụ Đức, Bồng Sơn, Hoài Nhơn, Bình Định|10042021

        List<String> textSplit = barcodeFilled.split('|');

        if (textSplit.length == 7 && !tempBarcode.contains(barcodeFilled)) {
          tempBarcode.add(barcodeFilled);

          CCCDInfo cccdInfo = CCCDInfo(
              textSplit[2], formatDateString(textSplit[3]), textSplit[0]);

          sendCCCD(cccdInfo);
        } else if (textSplit.length == 11 &&
            !tempBarcode.contains(barcodeFilled)) {
          tempBarcode.add(barcodeFilled);

          CCCDInfo cccdInfo = CCCDInfo(
              textSplit[2], formatDateString(textSplit[3]), textSplit[0]);
          sendCCCD(cccdInfo);
        }
      });
    } on PlatformException {
      Get.snackbar("Thông báo", "Lỗi barcode");
    }

    update();
  }

  void sendCCCD(CCCDInfo cccdInfo) {
    FirebaseManager().rootPath.child('cccd').set(cccdInfo.toJson());

    AssetsAudioPlayer.newPlayer().open(
      Audio("assets/beep.mp3"),
      showNotification: true,
    );
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;

  void saveData() {
    try {
      List<String> tempBarcode = [];
      if (streamSaveData != null) {
        streamSaveData!.cancel();
      }
      streamSaveData = FlutterBarcodeScanner.getBarcodeStreamReceiver(
              "#ff6666", 'Cancel', true, ScanMode.DEFAULT)
          ?.listen((barcode) async {
        String barcodeFilled = barcode.trim().toString().toUpperCase();

//052093000573|215277482|Lê Đi Xơn|08071993|Nam|Tổ 2, Khu phố Phụ Đức, Bồng Sơn, Hoài Nhơn, Bình Định|10042021

        List<String> textSplit = barcodeFilled.split('|');

        if (textSplit.length == 7 && !tempBarcode.contains(barcodeFilled)) {
          tempBarcode.add(barcodeFilled);

          CCCDInfo cccdInfo = CCCDInfo(
              textSplit[2], formatDateString(textSplit[3]), textSplit[0]);
          cccdInfo.DiaChi = textSplit[5];
          cccdInfo.NgayLamCCCD = formatDateString(textSplit[6]);
          cccdInfo.TimeStamp = DateTime.now().millisecondsSinceEpoch.toString();

          FirebaseManager()
              .rootPath
              .child("listcccd")
              .push()
              .set(cccdInfo.toJsonFull());

          AssetsAudioPlayer.newPlayer().open(
            Audio("assets/beep.mp3"),
            showNotification: true,
          );

//check is exist in firebase on child "listcccd"
        } else if (textSplit.length == 11 &&
            !tempBarcode.contains(barcodeFilled)) {
          tempBarcode.add(barcodeFilled);

          CCCDInfo cccdInfo = CCCDInfo(
              textSplit[2], formatDateString(textSplit[3]), textSplit[0]);
          cccdInfo.DiaChi = textSplit[5];
          cccdInfo.NgayLamCCCD = formatDateString(textSplit[6]);
          cccdInfo.TimeStamp = DateTime.now().millisecondsSinceEpoch.toString();

          FirebaseManager()
              .rootPath
              .child("listcccd")
              .push()
              .set(cccdInfo.toJsonFull());

          AssetsAudioPlayer.newPlayer().open(
            Audio("assets/beep.mp3"),
            showNotification: true,
          );
        }
      });

      // listTempMV = [];
    } on PlatformException {
      Get.snackbar("Thông báo", "Lỗi barcode");

      // listTempMV = [];
    }

    //thuc hien cong viec trong nay

    update();
  }

  Future<void> layDanhSach() async {
    try {
      var data = await FirebaseManager().rootPath.child("listcccd").once();
      totalCCCD.clear();

      Map<dynamic, dynamic> map = data.snapshot.value as Map<dynamic, dynamic>;
      for (var json in map.entries) {
        CCCDInfo cccdInfo = CCCDInfo("", "", "");
        cccdInfo.Name = json.value['Name'];
        cccdInfo.Id = json.value['Id'];
        cccdInfo.NgaySinh = json.value['NgaySinh'];
        cccdInfo.TimeStamp = json.value['TimeStamp'];
        //   cccdInfo.fromJson(inMap.value);

        totalCCCD.add(cccdInfo);
      }
      //order by timestamp
      totalCCCD.sort((a, b) => a.TimeStamp.compareTo(b.TimeStamp));

// Cập nhật chỉ số và tên hiện tại
      if (totalCCCD.isNotEmpty) {
        indexCurrent.value = 0;
        nameCurrent.value = totalCCCD[indexCurrent.value].Name;
      } else {
        indexCurrent.value = 0;
        nameCurrent.value = "";
      }
      update();
    } catch (e) {
      Get.snackbar("Thông báo", "Lỗi barcode");

      // listTempMV = [];
    }
  }

  void deleteData() {
    FirebaseManager().rootPath.child("listcccd").remove();
    totalCCCD.clear();

    indexCurrent.value = 0;

    nameCurrent.value = "";
    update();
  }

  void previousCCCD() {
    //decrease totalCCCD down 1
    if (indexCurrent.value == 0) return;
    indexCurrent.value = indexCurrent.value - 1;
    nameCurrent.value = totalCCCD[indexCurrent.value].Name;
    if (isRunning.value) {
      sendCCCD(totalCCCD[indexCurrent.value]);
    }
  }

  void nextCCCD() {
    //decrease totalCCCD down 1
    if (indexCurrent.value == totalCCCD.length - 1) return;
    indexCurrent.value = indexCurrent.value + 1;
    nameCurrent.value = totalCCCD[indexCurrent.value].Name;
    if (isRunning.value) {
      sendCCCD(totalCCCD[indexCurrent.value]);
    }
  }

  void sendAutoRunToFirebase(bool isAuto) {
    FirebaseManager().sendAutoRunToFirebase(isAuto);
  }

  void onListenNotification(MessageReceiveModel message) {
    if (message.Lenh == "continueCCCD") {
      if (isAutoRun.value) {
        nextCCCD();
      }
    }
  }
}
