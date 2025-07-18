import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'package:get/get.dart';

import '../../../managers/fireabaseManager.dart';
import '../models/MessageModel.dart';
import '../models/cccdInfo.dart';

class HomeController extends GetxController {
  final count = 0.obs;
  final nameCurrent = "".obs;
  final isRunning = false.obs;
  final totalCCCD = <CCCDInfo>[].obs;
  final indexCurrent = 0.obs;
  final isAutoRun = false.obs;
  final errorCCCDList = <CCCDInfo>[].obs;
  final currentPostalCode = "".obs;

  final scrollController = ScrollController();
  final postalCodeController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Listen to postal code changes
    postalCodeController.addListener(() {
      currentPostalCode.value = postalCodeController.text;
    });
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
  int number = 0;
  void test() {
//thay sau chữ Ngọc là số cho trước ví dụ Ngọc 1
    number++;
    String barcodeFilled =
        "052321010762||Dương Lê Như Ngọc $number|20112021|Nữ|Tổ 7, Khu Phố Thiện Đức Bắc, Hoài Hương, Hoài Nhơn, Bình Định|06112024||Dương Văn Thông|Lê Thị Bích Nhiên|";
    List<String> textSplit = barcodeFilled.split('|');

    // Kiểm tra điều kiện
    if ((textSplit.length == 7 || textSplit.length == 11)) {
      CCCDInfo cccdInfo =
          CCCDInfo(textSplit[2], formatDateString(textSplit[3]), textSplit[0]);
      // Thêm giới tính nếu có
      if (textSplit.length >= 5) {
        cccdInfo.gioiTinh = textSplit[4];
      }
      // Thêm mã bưu gửi hiện tại
      cccdInfo.maBuuGui =
          currentPostalCode.value.isNotEmpty ? currentPostalCode.value : null;

      if (!isAutoRun.value) {
        sendCCCD(cccdInfo);
      } else {
        totalCCCD.add(cccdInfo);
      }
      // Nếu isAutoRun bật và không có yêu cầu đang gửi, bắt đầu xử lý hàng đợi
      if (isAutoRun.value && !isSending) {
        processCCCD();
      }
    }
  }

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

        List<String> textSplit = barcodeFilled.split('|');

        // Kiểm tra điều kiện
        if ((textSplit.length == 7 || textSplit.length == 11) &&
            !tempBarcode.contains(barcodeFilled)) {
          tempBarcode.add(barcodeFilled);
          CCCDInfo cccdInfo = CCCDInfo(
              textSplit[2], formatDateString(textSplit[3]), textSplit[0]);
          // Thêm giới tính nếu có
          if (textSplit.length >= 5) {
            cccdInfo.gioiTinh = textSplit[4];
            cccdInfo.DiaChi = textSplit[5];
          }
          // Thêm mã bưu gửi hiện tại
          cccdInfo.maBuuGui = currentPostalCode.value.isNotEmpty
              ? currentPostalCode.value
              : null;
          //tạo rung nhẹ
          AssetsAudioPlayer.newPlayer().open(
            Audio("assets/beep.mp3"),
          );
          if (!isAutoRun.value) {
            sendCCCD(cccdInfo);
          } else {
            totalCCCD.add(cccdInfo);
          }
          // Nếu isAutoRun bật và không có yêu cầu đang gửi, bắt đầu xử lý hàng đợi
          if (isAutoRun.value && !isSending) {
            processCCCD();
          }
        }
      });
    } on PlatformException {
      Get.snackbar("Thông báo", "Lỗi barcode");
    }

    update();
  }

  bool isSending = false;

  void sendCCCD(CCCDInfo cccdInfo) {
    FirebaseManager().rootPath.child('cccd').set(cccdInfo.toJson());
  }

  void processCCCD() {
    // Chỉ xử lý khi isAutoRun được bật, không có yêu cầu đang gửi và còn dữ liệu chưa xử lý
    if (isAutoRun.value &&
        !isSending &&
        indexCurrent.value < totalCCCD.length) {
      // Lấy CCCDInfo tiếp theo
      CCCDInfo cccdInfo = totalCCCD[indexCurrent.value];
      nameCurrent.value = cccdInfo.Name;

      // Đánh dấu là đang gửi
      isSending = true;

      // Gửi CCCD
      sendCCCD(cccdInfo);

      // Logic chờ phản hồi và xử lý mục tiếp theo sẽ nằm trong onListenNotification
    } else if (!isAutoRun.value) {
      isSending = false;
      // Có thể reset indexCurrent.value = 0; ở đây nếu cần khi tắt auto run
    }
  }

  @override
  void onClose() {
    postalCodeController.dispose();
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
        List<String> textSplit = barcodeFilled.split('|');

        // Kiểm tra điều kiện và gọi hàm xử lý
        if ((textSplit.length == 7 || textSplit.length == 11) &&
            !tempBarcode.contains(barcodeFilled)) {
          tempBarcode.add(barcodeFilled);
          await _processCCCDInfo(textSplit);
        }
      });
    } on PlatformException {
      Get.snackbar("Thông báo", "Lỗi barcode");
    }

    update();
  }

  Future<void> _processCCCDInfo(List<String> textSplit) async {
    CCCDInfo cccdInfo =
        CCCDInfo(textSplit[2], formatDateString(textSplit[3]), textSplit[0]);

    // Cập nhật thông tin cho CCCDInfo
    cccdInfo.gioiTinh = textSplit.length >= 5 ? textSplit[4] : "";
    cccdInfo.DiaChi = textSplit.length == 11
        ? textSplit[5]
        : (textSplit.length == 7 ? textSplit[5] : "");
    cccdInfo.NgayLamCCCD = formatDateString(textSplit.last);
    cccdInfo.TimeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    // Gửi dữ liệu lên Firebase
    await FirebaseManager()
        .rootPath
        .child("listcccd")
        .push()
        .set(cccdInfo.toJsonFull());

    // Phát âm thanh thông báo
    await AssetsAudioPlayer.newPlayer().open(
      Audio("assets/beep.mp3"),
      showNotification: true,
    );
  }

  Future<void> layDanhSach() async {
    try {
      // Thiết lập listener cho dữ liệu trong Firebase
      FirebaseManager().rootPath.child("listcccd").onValue.listen((event) {
        Map<dynamic, dynamic> map =
            event.snapshot.value as Map<dynamic, dynamic>;

        // Tạo một danh sách tạm thời để lưu trữ các ID đã thấy
        List<String> existingIds = totalCCCD.map((item) => item.Id).toList();

        for (var json in map.entries) {
          CCCDInfo cccdInfo = CCCDInfo("", "", "");
          cccdInfo.Name = json.value['Name'];
          cccdInfo.Id = json.value['Id'];
          cccdInfo.NgaySinh = json.value['NgaySinh'];
          cccdInfo.TimeStamp = json.value['TimeStamp'];
          cccdInfo.gioiTinh = json.value['gioiTinh'] ?? "";
          cccdInfo.DiaChi = json.value['DiaChi'] ?? "";
          cccdInfo.NgayLamCCCD = json.value['NgayLamCCCD'] ?? "";

          // Kiểm tra xem mục đã tồn tại chưa
          if (!existingIds.contains(cccdInfo.Id)) {
            totalCCCD.add(cccdInfo); // Thêm mới
          } else {
            // Cập nhật thông tin nếu mục đã tồn tại
            int index = totalCCCD.indexWhere((item) => item.Id == cccdInfo.Id);
            totalCCCD[index] = cccdInfo; // Cập nhật thông tin
          }
        }

        // Sắp xếp theo timestamp
        totalCCCD.sort((a, b) => a.TimeStamp.compareTo(b.TimeStamp));

        // Cập nhật chỉ số và tên hiện tại
        if (totalCCCD.isNotEmpty) {
          indexCurrent.value = 0;
          nameCurrent.value = totalCCCD[indexCurrent.value].Name;
        } else {
          indexCurrent.value = 0;
          nameCurrent.value = "";
        }

        update(); // Cập nhật trạng thái
      });
    } catch (e) {
      Get.snackbar("Thông báo", "Lỗi khi lấy danh sách");
    }
  }

  void deleteData() {
    FirebaseManager().rootPath.child("listcccd").remove();
    totalCCCD.clear();
    isAutoRun.value = false;
    isSending = false;

    indexCurrent.value = 0;

    nameCurrent.value = "";
    update();
  }

  void previousCCCD() {
    if (isSending) return;
    //decrease totalCCCD down 1
    if (indexCurrent.value == 0) return;
    indexCurrent.value = indexCurrent.value - 1;
    nameCurrent.value = totalCCCD[indexCurrent.value].Name;
    if (isRunning.value) {
      sendCCCD(totalCCCD[indexCurrent.value]);
    }
  }

  void nextCCCD() {
    if (isSending) return; // Không cho phép gửi tiếp khi đang gửi
    //decrease totalCCCD down 1
    if (indexCurrent.value == totalCCCD.length - 1) return;
    indexCurrent.value = indexCurrent.value + 1;
    nameCurrent.value = totalCCCD[indexCurrent.value].Name;
    if (isRunning.value) {
      sendCCCD(totalCCCD[indexCurrent.value]);
    }
  }

  void resendCurrentCCCD() {
    if (isAutoRun.value && isSending && indexCurrent.value < totalCCCD.length) {
      sendCCCD(totalCCCD[indexCurrent.value]);
      Get.snackbar("Thông báo", "Đã gửi lại mã hiệu hiện tại.");
    } else if (isAutoRun.value && !isSending) {
      Get.snackbar("Thông báo", "Không có mã hiệu nào đang chờ gửi lại.");
    } else if (!isAutoRun.value) {
      Get.snackbar("Thông báo", "Chế độ tự động chạy không được bật.");
    }
  }

  void sendAutoRunToFirebase(bool isAuto) {
    FirebaseManager().sendAutoRunToFirebase(isAuto);
  }

  void onListenNotification(MessageReceiveModel message) {
    if (message.Lenh == "continueCCCD") {
      isSending = false;
      if (isAutoRun.value) {
        indexCurrent.value++;
        // Sau khi nhận được tín hiệu hoàn thành và tăng index, gọi lại processCCCD để xử lý mục tiếp theo
        processCCCD();
      }
    }
  }

  /// Removes Vietnamese diacritics from text for search comparison
  String removeDiacritics(String text) {
    // Define regex patterns for each Vietnamese vowel group and đ
    final replacements = [
      // Lowercase vowels
      {'pattern': r'[àáạảãâầấậẩẫăằắặẳẵ]', 'replacement': 'a'},
      {'pattern': r'[èéẹẻẽêềếệểễ]', 'replacement': 'e'},
      {'pattern': r'[ìíịỉĩ]', 'replacement': 'i'},
      {'pattern': r'[òóọỏõôồốộổỗơờớợởỡ]', 'replacement': 'o'},
      {'pattern': r'[ùúụủũưừứựửữ]', 'replacement': 'u'},
      {'pattern': r'[ỳýỵỷỹ]', 'replacement': 'y'},
      {'pattern': r'đ', 'replacement': 'd'},

      // Uppercase vowels
      {'pattern': r'[ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴ]', 'replacement': 'A'},
      {'pattern': r'[ÈÉẸẺẼÊỀẾỆỂỄ]', 'replacement': 'E'},
      {'pattern': r'[ÌÍỊỈĨ]', 'replacement': 'I'},
      {'pattern': r'[ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠ]', 'replacement': 'O'},
      {'pattern': r'[ÙÚỤỦŨƯỪỨỰỬỮ]', 'replacement': 'U'},
      {'pattern': r'[ỲÝỴỶỸ]', 'replacement': 'Y'},
      {'pattern': r'Đ', 'replacement': 'D'},
    ];

    String result = text;
    for (var replacement in replacements) {
      result = result.replaceAll(
          RegExp(replacement['pattern']!), replacement['replacement']!);
    }
    return result;
  }

  void searchCCCD(String value) {
    // Skip search if value is empty
    if (value.trim().isEmpty) {
      return;
    }

    // Normalize search value by removing diacritics and converting to lowercase
    String normalizedSearchValue = removeDiacritics(value.trim().toLowerCase());

    // Find the first matching CCCD by comparing normalized names
    int index = totalCCCD.indexWhere((item) {
      String normalizedName = removeDiacritics(item.Name.toLowerCase());
      return normalizedName.contains(normalizedSearchValue);
    });

    if (index != -1) {
      // Calculate accurate scroll position based on actual ListView item structure:
      // - Card with vertical margin: 4.0 * 2 = 8.0
      // - ListTile with leading icon, title, and subtitle: ~72.0
      // - Card internal padding and content: ~8.0
      // Total estimated height per item: ~88.0
      double estimatedItemHeight = 88.0;

      // Calculate target scroll position
      double targetPosition = index * estimatedItemHeight;

      // Ensure we don't scroll beyond the maximum scroll extent
      double maxScrollExtent = scrollController.position.maxScrollExtent;
      double finalPosition =
          targetPosition > maxScrollExtent ? maxScrollExtent : targetPosition;

      // Animate to the calculated position
      scrollController.animateTo(
        finalPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // Method để copy tất cả dữ liệu CCCD theo format yêu cầu
  void copyAllCCCDData() {
    if (totalCCCD.isEmpty) {
      Get.snackbar("Thông báo", "Không có dữ liệu để copy");
      return;
    }

    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < totalCCCD.length; i++) {
      buffer.writeln(totalCCCD[i].toCopyFormat(i + 1));
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    Get.snackbar(
        "Thành công", "Đã copy ${totalCCCD.length} bản ghi vào clipboard");
  }

  /// Add current CCCD to error list and advance to next CCCD
  void addCurrentCCCDToError() {
    if (!isAutoRun.value) {
      Get.snackbar(
          "Thông báo", "Chức năng này chỉ hoạt động khi bật tự động chạy");
      return;
    }

    if (indexCurrent.value < totalCCCD.length) {
      CCCDInfo currentCCCD = totalCCCD[indexCurrent.value];

      // Add to error list if not already there
      if (!errorCCCDList.any((item) => item.Id == currentCCCD.Id)) {
        errorCCCDList.add(currentCCCD);
        Get.snackbar(
            "Thông báo", "Đã thêm ${currentCCCD.Name} vào danh sách lỗi");
      }

      // Advance to next CCCD
      advanceToNextCCCD();
    }
  }

  /// Advance to the next CCCD in auto-run mode
  void advanceToNextCCCD() {
    if (indexCurrent.value < totalCCCD.length - 1) {
      indexCurrent.value++;
      nameCurrent.value = totalCCCD[indexCurrent.value].Name;

      // Continue processing if auto-run is enabled
      if (isAutoRun.value && !isSending) {
        processCCCD();
      }
    } else {
      // Reached end of list
      Get.snackbar("Thông báo", "Đã xử lý hết danh sách CCCD");
    }
  }

  /// Navigate to CCCD Error page
  void navigateToCCCDErrorPage() {
    Get.toNamed('/cccd_error', arguments: errorCCCDList.toList());
  }

  /// Update postal code for all future scanned CCCDs
  void updatePostalCode(String newPostalCode) {
    currentPostalCode.value = newPostalCode;
    postalCodeController.text = newPostalCode;
  }

  /// Delete all CCCD data with confirmation dialog
  void deleteAllCCCDData() {
    if (totalCCCD.isEmpty) {
      Get.snackbar("Thông báo", "Danh sách CCCD đã trống");
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Xác nhận xóa tất cả'),
        content: Text(
            'Bạn có chắc muốn xóa tất cả ${totalCCCD.length} CCCD?\nHành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              // Clear all CCCD data
              totalCCCD.clear();
              errorCCCDList.clear();

              // Reset UI state
              indexCurrent.value = 0;
              nameCurrent.value = "";
              isAutoRun.value = false;
              isSending = false;

              // Clear Firebase data
              FirebaseManager().rootPath.child("listcccd").remove();

              Get.back();
              Get.snackbar("Thành công", "Đã xóa tất cả dữ liệu CCCD");
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );
  }
}
