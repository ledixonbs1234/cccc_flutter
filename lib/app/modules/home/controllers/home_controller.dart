import 'dart:async';
import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:diacritic/diacritic.dart';
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
  final searchController = TextEditingController();

  // Fixed item extent for ListView - ensures precise scroll positioning
  static const double cccdItemExtent = 112.0;

  // Search results state management
  final searchResults = <CCCDInfo>[].obs;
  final searchQuery = "".obs;
  final isSearchActive = false.obs;
  final hasSearchText = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to postal code changes
    postalCodeController.addListener(() {
      currentPostalCode.value = postalCodeController.text;
    });
    totalCCCD.addAll(generateRandomCCCDData(50));
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

  /// Scan postal code using camera or QR code scanner
  void scanPostalCode() {
    try {
      // Use barcode scanner to scan postal code
      FlutterBarcodeScanner.scanBarcode(
        "#ff6666", // Scanner line color
        "Hủy", // Cancel button text
        true, // Show flash icon
        ScanMode.DEFAULT, // Scan mode
      ).then((scannedCode) {
        if (scannedCode != '-1' && scannedCode.isNotEmpty) {
          // Process the scanned postal code
          String cleanedCode = scannedCode.trim().toUpperCase();

          // Update postal code controller and reactive variable
          postalCodeController.text = cleanedCode;
          currentPostalCode.value = cleanedCode;

          // Show success feedback
          Get.snackbar(
            "Quét thành công",
            "Đã quét mã bưu gửi: $cleanedCode",
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.primaryContainer,
            colorText: Get.theme.colorScheme.onPrimaryContainer,
            icon: Icon(
              Icons.check_circle,
              color: Get.theme.colorScheme.onPrimaryContainer,
            ),
          );

          // Play success sound
          AssetsAudioPlayer.newPlayer().open(
            Audio("assets/beep.mp3"),
          );
        } else {
          // Show cancellation or error message
          Get.snackbar(
            "Quét bị hủy",
            "Việc quét mã bưu gửi đã bị hủy",
            duration: const Duration(seconds: 2),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.errorContainer,
            colorText: Get.theme.colorScheme.onErrorContainer,
          );
        }
      });
    } on PlatformException catch (e) {
      // Handle scanning errors
      Get.snackbar(
        "Lỗi quét mã",
        "Không thể quét mã bưu gửi: ${e.message}",
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        icon: Icon(
          Icons.error,
          color: Get.theme.colorScheme.onErrorContainer,
        ),
      );
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
    searchController.dispose();
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
    // Debug logging for message received (remove in production)
    print(
        "Firebase message received - Lenh: ${message.Lenh}, DoiTuong: ${message.DoiTuong}");

    if (message.Lenh == "continueCCCD") {
      isSending = false;
      if (isAutoRun.value) {
        indexCurrent.value++;
        // Sau khi nhận được tín hiệu hoàn thành và tăng index, gọi lại processCCCD để xử lý mục tiếp theo
        processCCCD();
      }
    } else if (message.Lenh == "sendMaHieu") {
      // Handle postal code update from TypeScript function
      String receivedPostalCode = message.DoiTuong.trim();
      print(
          "Processing sendMaHieu command with postal code: '$receivedPostalCode'");

      if (receivedPostalCode.isNotEmpty) {
        // Update the postal code controller and reactive variable
        postalCodeController.text = receivedPostalCode;
        currentPostalCode.value = receivedPostalCode;

        print("Postal code updated successfully: $receivedPostalCode");

        // Show notification to user
        Get.snackbar(
          "Mã hiệu đã cập nhật",
          "Đã nhận mã hiệu: $receivedPostalCode",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        print("Warning: Received empty postal code");
        Get.snackbar(
          "Cảnh báo",
          "Mã hiệu nhận được rỗng",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  /// Test function to simulate receiving postal code from TypeScript
  /// This can be called manually to test the functionality
  void testPostalCodeReceive(String testPostalCode) {
    MessageReceiveModel testMessage =
        MessageReceiveModel("sendMaHieu", testPostalCode);
    onListenNotification(testMessage);
  }

  /// Test function to verify search scroll positioning with fixed itemExtent
  /// This demonstrates the improved scroll accuracy using Flutter's built-in positioning
  void testSearchScrollPosition(int targetIndex) {
    if (targetIndex >= 0 && targetIndex < totalCCCD.length) {
      String targetName = totalCCCD[targetIndex].Name;

      // Test the search functionality
      searchCCCD(targetName.split(' ').first); // Search with first name part

      // Log the results for verification (remove in production)
      print("Testing search scroll to index $targetIndex: $targetName");
      print("Using fixed itemExtent: $cccdItemExtent");
      print("Expected scroll position: ${targetIndex * cccdItemExtent}");
    }
  }

  /// Test function to verify search clearing functionality
  /// This demonstrates that both search results and TextField are properly cleared
  void testSearchClearFunctionality() {
    // Simulate a search
    searchController.text = "Test Search";
    searchCCCD("Nguyễn");

    print(
        "Before clear - TextField: '${searchController.text}', Results: ${searchResults.length}, Active: ${isSearchActive.value}");

    // Clear the search
    clearSearch();

    print(
        "After clear - TextField: '${searchController.text}', Results: ${searchResults.length}, Active: ${isSearchActive.value}");
  }

  /// Removes Vietnamese diacritics from text for search comparison
  String chuyenSangKoDau(String text) {
    return removeDiacritics(text);
  }

  void searchCCCD(String value) {
    // Update hasSearchText reactive variable
    hasSearchText.value = value.trim().isNotEmpty;

    // Clear previous search results if search is empty
    if (value.trim().isEmpty) {
      clearSearch();
      return;
    }

    // Update search query
    searchQuery.value = value.trim();

    // Normalize search value by removing diacritics and converting to lowercase
    String normalizedSearchValue = chuyenSangKoDau(value.trim().toLowerCase());

    // Find all matching CCCDs by comparing normalized names and IDs
    List<CCCDInfo> foundItems = [];
    for (int i = 0; i < totalCCCD.length; i++) {
      CCCDInfo item = totalCCCD[i];
      String normalizedName = chuyenSangKoDau(item.Name.toLowerCase());
      String normalizedId = item.Id.toLowerCase();

      // Search in both name and ID
      if (normalizedName.contains(normalizedSearchValue) ||
          normalizedId.contains(normalizedSearchValue)) {
        foundItems.add(item);
        break;
      }
    }

    // Update search results
    searchResults.value = foundItems;
    isSearchActive.value = true;
  }

  /// Clear search results and reset search state
  void clearSearch() {
    searchResults.clear();
    searchQuery.value = "";
    isSearchActive.value = false;
    hasSearchText.value = false;
    // Clear the search text field
    searchController.clear();
  }

  /// Navigate to a specific CCCD item in the main list
  void goToSearchResult(CCCDInfo cccdItem) {
    // Find the index of the item in the main list
    int index = totalCCCD.indexWhere((item) => item.Id == cccdItem.Id);

    if (index != -1) {
      // Update current index to highlight the item
      indexCurrent.value = index;
      nameCurrent.value = totalCCCD[index].Name;

      // Calculate exact scroll position using the fixed item extent
      double targetPosition = index * cccdItemExtent;

      // Add offset to center the found item in the viewport
      double viewportCenterOffset = 160.0;
      double centeredPosition = targetPosition - viewportCenterOffset;

      // Ensure we don't scroll beyond valid bounds
      double maxScrollExtent = scrollController.position.maxScrollExtent;
      double finalPosition = centeredPosition.clamp(0.0, maxScrollExtent);

      // Animate to the calculated position with smooth easing
      scrollController.animateTo(
        finalPosition,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );

      // Show feedback
      Get.snackbar(
        "Đã chuyển đến",
        "Đã chuyển đến: ${cccdItem.Name}",
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  List<CCCDInfo> generateRandomCCCDData(int count) {
    List<CCCDInfo> sampleData = [];
    Random random = Random();

    // Danh sách họ, tên đệm và tên Việt Nam ngẫu nhiên
    List<String> lastNames = [
      'Nguyễn',
      'Trần',
      'Lê',
      'Phạm',
      'Hoàng',
      'Huỳnh',
      'Võ',
      'Đặng',
      'Bùi',
      'Đỗ'
    ];
    List<String> middleNames = [
      'Văn',
      'Thị',
      'Minh',
      'Hữu',
      'Đức',
      'Thanh',
      'Ngọc',
      'Gia',
      'Bảo',
      'Quốc'
    ];
    List<String> firstNames = [
      'An',
      'Bình',
      'Cường',
      'Dũng',
      'Hà',
      'Hải',
      'Hiếu',
      'Hùng',
      'Huy',
      'Khánh',
      'Linh',
      'Long',
      'Minh',
      'Nam',
      'Nga',
      'Ngọc',
      'Phong',
      'Phúc',
      'Phương',
      'Quân',
      'Quỳnh',
      'Sơn',
      'Thảo',
      'Trang',
      'Tùng',
      'Việt'
    ];

    // Danh sách địa chỉ mẫu
    List<String> sampleAddresses = [
      'Tổ 7, Khu Phố Thiện Đức Bắc, Hoài Hương, Hoài Nhơn, Bình Định',
      'Khu Phố 6 Bồng Sơn, An Khê, Gia Lai',
      'Diễn Khánh, Hoài Đức, Hà Nội',
      'Phường 1, Quận 3, TP. Hồ Chí Minh',
      'Xã Tân Phú, Huyện Đức Trọng, Lâm Đồng',
      'Phường Hải Châu, Quận Hải Châu, Đà Nẵng',
      'Xã Phú Hòa, Huyện Krông Pắc, Đắk Lắk',
      'Phường Nguyễn Du, TP. Huế, Thừa Thiên Huế',
      'Xã Ea Kar, Huyện Ea Kar, Đắk Lắk',
      'Phường Tân An, TP. Buôn Ma Thuột, Đắk Lắk',
      'Số 10, đường Lý Thường Kiệt, Phường Trần Hưng Đạo, Quận Hoàn Kiếm, Hà Nội',
      'Thôn 3, xã Ea Tiêu, huyện Cư Kuin, tỉnh Đắk Lắk',
      'Số 25, ngõ 120, đường Hoàng Quốc Việt, Phường Nghĩa Tân, Quận Cầu Giấy, Hà Nội',
      'Ấp 2, xã Vĩnh Lộc A, huyện Bình Chánh, TP. Hồ Chí Minh',
      'Số 100, đường Hùng Vương, Phường 9, Quận 5, TP. Hồ Chí Minh',
      'Thôn An Lạc, xã Trưng Trắc, huyện Văn Lâm, tỉnh Hưng Yên'
    ];

    // Danh sách mã tỉnh/thành phố
    List<String> provinceCodes = [
      '001',
      '002',
      '004',
      '006',
      '008',
      '010',
      '011',
      '012',
      '014',
      '015',
      '017',
      '019',
      '020',
      '022',
      '024',
      '025',
      '026',
      '027',
      '030',
      '031',
      '033',
      '034',
      '035',
      '036',
      '037',
      '038',
      '040',
      '042',
      '044',
      '045',
      '046',
      '048',
      '049',
      '051',
      '052',
      '054',
      '056',
      '058',
      '060',
      '062',
      '064',
      '066',
      '067',
      '068',
      '070',
      '072',
      '074',
      '075',
      '077',
      '079',
      '080',
      '082',
      '083',
      '084',
      '086',
      '087',
      '089',
      '091',
      '092',
      '093',
      '094',
      '095',
      '096'
    ];

    for (int i = 0; i < count; i++) {
      // Tạo tên ngẫu nhiên
      String hoTen =
          '${lastNames[random.nextInt(lastNames.length)]} ${middleNames[random.nextInt(middleNames.length)]} ${firstNames[random.nextInt(firstNames.length)]}';

      // Tạo ngày sinh ngẫu nhiên (từ 1950 đến 2005)
      int year = (1950 + random.nextInt(56)) as int;
      int month = (1 + random.nextInt(12)) as int;
      int day = (1 + random.nextInt(28))
          as int; // Giả sử tháng nào cũng có 28 ngày cho đơn giản
      String ngaySinh =
          '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';

      // Chọn giới tính ngẫu nhiên
      String gioiTinh = random.nextBool() ? 'Nam' : 'Nữ';

      // Tạo số CCCD ngẫu nhiên
      String provinceCode = provinceCodes[random.nextInt(provinceCodes.length)];
      String centuryCode = (year >= 2000)
          ? (gioiTinh == 'Nam' ? '2' : '3')
          : (gioiTinh == 'Nam' ? '0' : '1');
      String yearCode = year.toString().substring(2);
      String randomDigits = '';
      for (int j = 0; j < 6; j++) {
        randomDigits += random.nextInt(10).toString();
      }
      String cccdId = '$provinceCode$centuryCode$yearCode$randomDigits';

      CCCDInfo cccdInfo = CCCDInfo(hoTen, ngaySinh, cccdId);

      // Thêm thông tin bổ sung
      cccdInfo.gioiTinh = gioiTinh;
      cccdInfo.DiaChi = sampleAddresses[random.nextInt(sampleAddresses.length)];
      cccdInfo.NgayLamCCCD = '06/11/2024';
      cccdInfo.maBuuGui = 'BĐ${(590000 + random.nextInt(10000)).toString()}';

      sampleData.add(cccdInfo);
    }

    return sampleData;
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
        
        // Auto sync to Firebase
        _autoSyncErrorToFirebase();
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
      if (isAutoRun.value) {
        isSending = false;
        processCCCD();
      }
    } else {
      // Reached end of list
      Get.snackbar("Thông báo", "Đã xử lý hết danh sách CCCD");
    }
  }

  /// Navigate to CCCD Error page
  void navigateToCCCDErrorPage() {
    Get.toNamed('/cccd_error', arguments: {
      'errorList': errorCCCDList.toList(),
      'totalList': totalCCCD.toList(),
      'currentIndex': indexCurrent.value,
    });
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

  /// Auto sync error CCCD list to Firebase in background
  Future<void> _autoSyncErrorToFirebase() async {
    if (errorCCCDList.isEmpty) {
      // Clear Firebase data if local list is empty
      try {
        await FirebaseManager().rootPath.child('errorcccd').remove();
      } catch (e) {
        // Ignore errors when clearing empty data
      }
      return;
    }

    try {
      // Prepare data for sync
      Map<String, dynamic> recordsMap = {};
      final recordsRef =
          FirebaseManager().rootPath.child('errorcccd').child('records');

      for (int i = 0; i < errorCCCDList.length; i++) {
        CCCDInfo errorCCCD = errorCCCDList[i];

        Map<String, dynamic> errorRecord =
            Map<String, dynamic>.from(errorCCCD.toJsonFull());
        errorRecord['errorIndex'] = i + 1;
        errorRecord['errorTimestamp'] =
            DateTime.now().millisecondsSinceEpoch.toString();
        
        // Add position in total list
        int position = totalCCCD.indexWhere((item) => item.Id == errorCCCD.Id);
        if (position != -1) {
          errorRecord['positionInTotalList'] = position + 1;
          errorRecord['totalListCount'] = totalCCCD.length;
        }

        // Create unique key for each record
        String? uniqueKey = recordsRef.push().key;
        if (uniqueKey != null) {
          recordsMap[uniqueKey] = errorRecord;
        }
      }

      // Prepare final payload
      Map<String, dynamic> finalPayload = {
        'metadata': {
          'totalErrorRecords': errorCCCDList.length,
          'syncTimestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'syncDate': DateTime.now().toIso8601String(),
          'autoSync': true,
          'currentIndex': indexCurrent.value,
        },
        'records': recordsMap,
      };

      // Sync to Firebase
      await FirebaseManager().rootPath.child('errorcccd').set(finalPayload);
    } catch (e) {
      // Silent fail for auto sync to avoid interrupting user experience
      print('Auto sync error CCCD to Firebase failed: $e');
    }
  }
}
