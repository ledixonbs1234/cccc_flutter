import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:get/get.dart';

import '../../../managers/fireabaseManager.dart';
import '../models/MessageModel.dart';
import '../models/cccdInfo.dart';

enum StatusType { none, success, error, info, warning }

class HomeController extends GetxController {
  final count = 0.obs;
  final nameCurrent = "".obs;
  final isRunning = false.obs;
  final totalCCCD = <CCCDInfo>[].obs;
  final indexCurrent = 0.obs;
  final isAutoRun = false.obs;
  final errorCCCDList = <CCCDInfo>[].obs;
  final currentPostalCode = "".obs;

  // NotFound retry tracking
  String? _lastNotFoundCCCDName;
  bool _hasTriedResend = false;

  final scrollController = ScrollController();
  final postalCodeController = TextEditingController();
  final searchController = TextEditingController();
  final firebaseKeyController = TextEditingController();

  // Firebase key state
  final currentFirebaseKey = "".obs;
  final isKeySetupComplete = false.obs;

  // Fixed item extent for ListView - ensures precise scroll positioning
  static const double cccdItemExtent = 112.0; // Search results state management
  final searchResults = <CCCDInfo>[].obs;
  final searchQuery = "".obs;
  final isSearchActive = false.obs;
  final hasSearchText = false.obs;

  // Audio settings
  final isSoundEnabled = true.obs;

  // Mobile scanner controller and flash state
  MobileScannerController? _mobileScannerController;
  final isFlashEnabled = false.obs;

  // Status message system
  final statusMessage = "".obs;
  final statusType = StatusType.none.obs;
  final lastOperationTime = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to postal code changes
    postalCodeController.addListener(() {
      currentPostalCode.value = postalCodeController.text;
    });

    // Initialize Firebase key
    _initializeFirebaseKey();

    // totalCCCD.addAll(generateRandomCCCDData(50));
  }

  void _initializeFirebaseKey() {
    final firebaseManager = FirebaseManager();
    final savedKey = firebaseManager.currentKey;
    if (savedKey != null && savedKey.isNotEmpty) {
      currentFirebaseKey.value = savedKey;
      firebaseKeyController.text = savedKey;
      isKeySetupComplete.value = true;
    } else {
      isKeySetupComplete.value = false;
    }
  }

  // Helper method to play beep sound
  void _playBeepSound() {
    if (!isSoundEnabled.value) return; // Skip if sound is disabled

    try {
      // Create a new AudioPlayer instance for each beep to allow overlapping sounds
      final beepPlayer = AudioPlayer();
      beepPlayer.play(AssetSource('beep.mp3'));

      // Auto-dispose the player after sound completes
      beepPlayer.onPlayerComplete.listen((_) {
        beepPlayer.dispose();
      });
    } catch (e) {
      print('Error playing beep sound: $e');
    }
  }

  // Status message management methods
  void showStatusMessage(String message, StatusType type) {
    statusMessage.value = message;
    statusType.value = type;
    lastOperationTime.value = DateTime.now();

    // Auto clear status after 5 seconds
    Timer(const Duration(seconds: 5), () {
      clearStatusMessage();
    });
  }

  void clearStatusMessage() {
    statusMessage.value = "";
    statusType.value = StatusType.none;
  }

  void showSuccessMessage(String message) {
    showStatusMessage(message, StatusType.success);
  }

  void showErrorMessage(String message) {
    showStatusMessage(message, StatusType.error);
  }

  void showInfoMessage(String message) {
    showStatusMessage(message, StatusType.info);
  }

  void showWarningMessage(String message) {
    showStatusMessage(message, StatusType.warning);
  }

  /// Toggle sound on/off
  void toggleSound() {
    isSoundEnabled.value = !isSoundEnabled.value;
    showInfoMessage(
        isSoundEnabled.value ? "Đã bật âm thanh beep" : "Đã tắt âm thanh beep");
  }

  /// Toggle flash on/off for mobile scanner
  void _toggleFlash() {
    try {
      isFlashEnabled.value = !isFlashEnabled.value;
      _mobileScannerController?.toggleTorch();

      showInfoMessage(
          isFlashEnabled.value ? "Đã bật đèn flash" : "Đã tắt đèn flash");
    } catch (e) {
      showErrorMessage("Không thể bật/tắt đèn flash: $e");
    }
  }

  /// Dispose mobile scanner controller safely
  void _disposeMobileScannerController() {
    try {
      _mobileScannerController?.dispose();
      _mobileScannerController = null;
      isFlashEnabled.value = false;
      // Disable wakelock when closing scanner
      WakelockPlus.disable();
    } catch (e) {
      print('Error disposing mobile scanner controller: $e');
    }
  }

  @override
  void onReady() {
    super.onReady();
    test();
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
        CCCDInfo? existingCCCD = totalCCCD
            .firstWhereOrNull((cccd) => cccd.maBuuGui == cccdInfo.maBuuGui);
        if (existingCCCD == null) {
          totalCCCD.add(cccdInfo);
        }
      }
      // Nếu isAutoRun bật và không có yêu cầu đang gửi, bắt đầu xử lý hàng đợi
      if (isAutoRun.value && !isSending) {
        processCCCD();
      }
    }
  }

  void capture() {
    // Navigate to mobile scanner page
    Get.to(
      () => _buildMobileScannerPage(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }

  /// Build mobile scanner page with custom UI
  Widget _buildMobileScannerPage() {
    // Enable wakelock to keep screen on while scanning
    WakelockPlus.enable();

    // Initialize scanner controller
    _mobileScannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: isFlashEnabled.value,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Quét CCCD',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Obx(() => IconButton(
                icon: Icon(
                  isFlashEnabled.value ? Icons.flash_on : Icons.flash_off,
                  color: isFlashEnabled.value ? Colors.yellow : Colors.white,
                ),
                onPressed: () {
                  _toggleFlash();
                },
              )),
          IconButton(
            icon: const Icon(Icons.science),
            onPressed: () {
              // Fallback to test capture
              _disposeMobileScannerController();
              Get.back();
              testCapture();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Mobile Scanner
          MobileScanner(
            controller: _mobileScannerController!,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _processCapturedBarcode(barcode.rawValue!);
                  // _disposeMobileScannerController();
                  // Get.back(); // Close scanner
                  break;
                }
              }
            },
          ), // Overlay with scanning area
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
            child: Stack(
              children: [
                // Scanning area cutout
                Center(
                  child: Container(
                    width: 300,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.green,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),

                // Instructions
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Đặt mã QR CCCD vào khung quét',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              icon: Icons.science,
                              label: 'Test',
                              onPressed: () {
                                Get.back();
                                testCapture();
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.close,
                              label: 'Đóng',
                              onPressed: () {
                                _disposeMobileScannerController();
                                Get.back();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build action button for scanner overlay
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Process captured barcode from mobile scanner
  void _processCapturedBarcode(String barcodeData) {
    try {
      String barcodeFilled = barcodeData.trim().toUpperCase();
      List<String> textSplit = barcodeFilled.split('|');

      // Kiểm tra điều kiện CCCD format
      if (textSplit.length == 7 || textSplit.length == 11) {
        CCCDInfo cccdInfo = CCCDInfo(
            textSplit[2], formatDateString(textSplit[3]), textSplit[0]);

        // Thêm giới tính nếu có
        if (textSplit.length >= 5) {
          cccdInfo.gioiTinh = textSplit[4];
          if (textSplit.length >= 6) {
            cccdInfo.DiaChi = textSplit[5];
          }
        }

        // Thêm mã bưu gửi hiện tại
        cccdInfo.maBuuGui =
            currentPostalCode.value.isNotEmpty ? currentPostalCode.value : null;

        if (!isAutoRun.value) {
          sendCCCD(cccdInfo);
          // Phát âm thanh thông báo
          _playBeepSound();
        } else {
          // Check existing cccd has same ID
          CCCDInfo? existingCCCD =
              totalCCCD.firstWhereOrNull((cccd) => cccd.Id == cccdInfo.Id);
          if (existingCCCD == null) {
            totalCCCD.add(cccdInfo);
          }
          // Always play beep sound
          _playBeepSound();
        }

        // Nếu isAutoRun bật và không có yêu cầu đang gửi, bắt đầu xử lý hàng đợi
        if (isAutoRun.value && !isSending) {
          processCCCD();
        }
      } else {
        // Invalid barcode format
        showErrorMessage("Mã QR không đúng định dạng CCCD");
      }
    } catch (e) {
      showErrorMessage("Lỗi xử lý mã QR: $e");
    }

    update();
  }

  /// Test function that simulates capture() with random barcode data
  Future<void> testCapture() async {
    try {
      // Generate random barcode data similar to real CCCD format
      String randomBarcode = _generateRandomBarcodeData();

      // Process the random barcode like real capture
      String barcodeFilled = randomBarcode.trim().toString().toUpperCase();
      List<String> textSplit = barcodeFilled.split('|');

      // Kiểm tra điều kiện (same logic as capture)
      if (textSplit.length == 7 || textSplit.length == 11) {
        CCCDInfo cccdInfo = CCCDInfo(
            textSplit[2], formatDateString(textSplit[3]), textSplit[0]);

        // Thêm giới tính nếu có
        if (textSplit.length >= 5) {
          cccdInfo.gioiTinh = textSplit[4];
          cccdInfo.DiaChi = textSplit[5];
        }

        // Thêm mã bưu gửi hiện tại
        cccdInfo.maBuuGui =
            currentPostalCode.value.isNotEmpty ? currentPostalCode.value : null;

        if (!isAutoRun.value) {
          sendCCCD(cccdInfo);
          // Phát âm thanh thông báo
          _playBeepSound();
        } else {
          // Check existing cccd has same ID (not maBuuGui to allow more variety)
          CCCDInfo? existingCCCD =
              totalCCCD.firstWhereOrNull((cccd) => cccd.Id == cccdInfo.Id);
          if (existingCCCD == null) {
            totalCCCD.add(cccdInfo);
          }
          // Always play beep sound in test mode regardless of duplicate
          _playBeepSound();
        }

        // Nếu isAutoRun bật và không có yêu cầu đang gửi, bắt đầu xử lý hàng đợi
        if (isAutoRun.value && !isSending) {
          processCCCD();
        }
      }
    } catch (e) {
      showErrorMessage("Lỗi test capture: $e");
    }

    update();
  }

  /// Generate random barcode data that matches CCCD format
  String _generateRandomBarcodeData() {
    Random random = Random();

    // Danh sách họ tên mẫu
    List<String> sampleNames = [
      "Nguyễn Văn An",
      "Trần Thị Bình",
      "Lê Minh Cường",
      "Phạm Thị Dung",
      "Hoàng Văn Hải",
      "Võ Thị Linh",
      "Đặng Minh Phúc",
      "Bùi Thị Nga",
      "Đỗ Văn Sơn",
      "Huỳnh Thị Thảo",
      "Dương Lê Như Ngọc",
      "Phan Văn Long",
      "Vũ Thị Mai",
      "Tôn Văn Nam",
      "Lý Thị Oanh"
    ];

    // Danh sách địa chỉ mẫu
    List<String> sampleAddresses = [
      "Tổ 7, Khu Phố Thiện Đức Bắc, Hoài Hương, Hoài Nhơn, Bình Định",
      "Phường 1, Quận 3, TP. Hồ Chí Minh",
      "Xã Tân Phú, Huyện Đức Trọng, Lâm Đồng",
      "Phường Hải Châu, Quận Hải Châu, Đà Nẵng",
      "Xã Phú Hòa, Huyện Krông Pắc, Đắk Lắk",
      "Phường Nguyễn Du, TP. Huế, Thừa Thiên Huế"
    ];

    // Generate random CCCD ID (12 digits) with timestamp to ensure uniqueness
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String cccdId = '';
    for (int i = 0; i < 8; i++) {
      cccdId += random.nextInt(10).toString();
    }
    // Add last 4 digits from timestamp for uniqueness
    cccdId += timestamp.substring(timestamp.length - 4);

    // Generate random birth date (DDMMYYYY format)
    int day = 1 + random.nextInt(28);
    int month = 1 + random.nextInt(12);
    int year = 1970 + random.nextInt(35); // 1970-2005
    String birthDate =
        '${day.toString().padLeft(2, '0')}${month.toString().padLeft(2, '0')}$year';

    // Random name and address
    String name = sampleNames[random.nextInt(sampleNames.length)];
    String gender = random.nextBool() ? "Nam" : "Nữ";
    String address = sampleAddresses[random.nextInt(sampleAddresses.length)];

    // Generate issue date (DDMMYYYY format) - usually recent
    String issueDate = "06112024";

    // Create barcode in format: ID||Name|BirthDate|Gender|Address|IssueDate||ParentName1|ParentName2|
    String barcode =
        "$cccdId||$name|$birthDate|$gender|$address|$issueDate||||";

    return barcode;
  }

  /// Scan postal code using mobile scanner
  void scanPostalCode() {
    // Navigate to postal code scanner page
    Get.to(
      () => _buildPostalCodeScannerPage(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }

  /// Build postal code scanner page with custom UI
  Widget _buildPostalCodeScannerPage() {
    // Enable wakelock to keep screen on while scanning
    WakelockPlus.enable();

    // Initialize scanner controller for postal code scanning
    MobileScannerController postalScannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Quét mã bưu gửi',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_off),
            onPressed: () {
              postalScannerController.toggleTorch();
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Fallback to manual input
              postalScannerController.dispose();
              WakelockPlus.disable();
              Get.back();
              _showManualPostalCodeInput();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Mobile Scanner
          MobileScanner(
            controller: postalScannerController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _processPostalCodeBarcode(
                      barcode.rawValue!, postalScannerController);
                  break;
                }
              }
            },
          ),
          // Overlay with scanning area
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
            child: Stack(
              children: [
                // Scanning area cutout for postal code
                Center(
                  child: Container(
                    width: 280,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blue,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
                // Instructions
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Đặt mã vạch hoặc QR code mã bưu gửi vào khung quét',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              icon: Icons.edit,
                              label: 'Nhập tay',
                              onPressed: () {
                                postalScannerController.dispose();
                                WakelockPlus.disable();
                                Get.back();
                                _showManualPostalCodeInput();
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.close,
                              label: 'Đóng',
                              onPressed: () {
                                postalScannerController.dispose();
                                WakelockPlus.disable();
                                Get.back();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Process captured postal code barcode
  void _processPostalCodeBarcode(
      String barcodeData, MobileScannerController controller) {
    try {
      String postalCode = barcodeData.trim();

      if (postalCode.isNotEmpty) {
        // Update postal code
        postalCodeController.text = postalCode;
        currentPostalCode.value = postalCode;

        // Play beep sound
        _playBeepSound();

        // Dispose scanner and go back
        controller.dispose();
        WakelockPlus.disable();
        Get.back();

        // Show success message
        Get.snackbar(
          "Thành công",
          "Đã cập nhật mã bưu gửi: $postalCode",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      } else {
        Get.snackbar(
          "Lỗi",
          "Mã bưu gửi không hợp lệ",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        "Lỗi xử lý",
        "Không thể xử lý mã bưu gửi: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }

    update();
  }

  /// Show manual postal code input dialog as fallback
  void _showManualPostalCodeInput() {
    Get.dialog(
      AlertDialog(
        title: const Text('Nhập mã bưu gửi'),
        content: TextField(
          controller: postalCodeController,
          decoration: const InputDecoration(
            labelText: 'Mã bưu gửi',
            border: OutlineInputBorder(),
            hintText: 'Ví dụ: BĐ590123',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              String enteredCode = postalCodeController.text.trim();
              if (enteredCode.isNotEmpty) {
                currentPostalCode.value = enteredCode;
                Get.back();
                Get.snackbar(
                  "Thành công",
                  "Đã cập nhật mã bưu gửi: $enteredCode",
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              } else {
                Get.snackbar(
                  "Lỗi",
                  "Vui lòng nhập mã bưu gửi",
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  bool isSending = false;

  Future<void> sendCCCD(CCCDInfo cccdInfo) async {
    await FirebaseManager().rootPath.child('cccd').set(cccdInfo.toJson());
  }

  void processCCCD() {
    // Chỉ xử lý khi isAutoRun được bật, không có yêu cầu đang gửi và còn dữ liệu chưa xử lý
    if (isAutoRun.value &&
        !isSending &&
        indexCurrent.value < totalCCCD.length) {
      // Reset notFound tracking when processing new CCCD

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
    _disposeMobileScannerController();
    postalCodeController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void increment() => count.value++;

  void saveData() {
    // TODO: Implement with mobile_scanner
    // For now, use testCapture and save to Firebase
    try {
      String randomBarcode = _generateRandomBarcodeData();
      String barcodeFilled = randomBarcode.trim().toString().toUpperCase();
      List<String> textSplit = barcodeFilled.split('|');

      // Kiểm tra điều kiện và gọi hàm xử lý
      if (textSplit.length == 7 || textSplit.length == 11) {
        _processCCCDInfo(textSplit);
        Get.snackbar("Test Save Data", "Đã lưu dữ liệu CCCD test vào Firebase");
      }
    } catch (e) {
      Get.snackbar("Thông báo", "Lỗi test save data: $e");
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
    _playBeepSound();
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
      // Reset notFound tracking on successful processing
      _resetNotFoundTracking();

      isSending = false;
      if (isAutoRun.value) {
        indexCurrent.value++;
        // Sau khi nhận được tín hiệu hoàn thành và tăng index, gọi lại processCCCD để xử lý mục tiếp theo
        processCCCD();
      }
    } else if (message.Lenh == "notFound") {
      _handleNotFoundMessage(message.DoiTuong);
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

  /// Handle notFound message with retry logic
  Future<void> _handleNotFoundMessage(String cccdName) async {
    if (_lastNotFoundCCCDName == cccdName && _hasTriedResend) {
      // Second time receiving notFound for same CCCD name - add to error list
      showErrorMessage(
          "CCCD $cccdName không tìm thấy sau 2 lần thử - đã thêm vào danh sách lỗi");
      addCurrentCCCDToError();
      _resetNotFoundTracking(); // Reset tracking for next CCCD
    } else {
      // First time or different CCCD - try resending
      _lastNotFoundCCCDName = cccdName;
      _hasTriedResend = true;

      showWarningMessage("Không tìm thấy CCCD $cccdName - đang thử gửi lại");
      await resetSameCCCDFirebase();

      // Resend current CCCD
      isSending = false;
      if (isAutoRun.value) {
        processCCCD();
      }
    }
  }

  /// Reset notFound tracking variables
  void _resetNotFoundTracking() {
    _lastNotFoundCCCDName = null;
    _hasTriedResend = false;
  }

  Future<void> resetSameCCCDFirebase() async {
    await sendCCCD(CCCDInfo("", "", ""));
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
      int year = 1950 + random.nextInt(56);
      int month = 1 + random.nextInt(12);
      int day = 1 +
          random.nextInt(28); // Giả sử tháng nào cũng có 28 ngày cho đơn giản
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
    })?.then((_) {
      // Re-sync error list when returning from error page
      _refreshErrorListFromFirebase();
    });
  }

  /// Refresh error list from Firebase after returning from error page
  Future<void> _refreshErrorListFromFirebase() async {
    try {
      final snapshot = await FirebaseManager()
          .rootPath
          .child('errorcccd')
          .child('records')
          .get();

      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic> records = snapshot.value as Map<dynamic, dynamic>;

        // Clear current error list
        errorCCCDList.clear();

        // Rebuild error list from Firebase
        records.forEach((key, value) {
          if (value is Map) {
            try {
              CCCDInfo cccdInfo = CCCDInfo("", "", "");
              cccdInfo.fromJson(Map<String, dynamic>.from(value));
              if (!errorCCCDList.any((item) => item.Id == cccdInfo.Id)) {
                errorCCCDList.add(cccdInfo);
              }
            } catch (e) {
              print('Error parsing CCCD from Firebase: $e');
            }
          }
        });

        print('Refreshed error list: ${errorCCCDList.length} items');
      } else {
        // No error records in Firebase, clear local list
        errorCCCDList.clear();
        print('No error records found in Firebase, cleared local list');
      }
    } catch (e) {
      print('Error refreshing error list from Firebase: $e');
    }
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

  /// Test method to simulate notFound retry logic
  void testNotFoundRetryLogic() {
    if (!isAutoRun.value) {
      Get.snackbar("Test Error", "Bật chế độ tự động để test");
      return;
    }

    if (totalCCCD.isEmpty) {
      Get.snackbar("Test Error", "Cần có ít nhất 1 CCCD để test");
      return;
    }

    String testCCCDName = totalCCCD[indexCurrent.value].Name;

    Get.dialog(
      AlertDialog(
        title: const Text('Test NotFound Retry Logic'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('CCCD hiện tại: $testCCCDName'),
            const SizedBox(height: 16),
            const Text('Chọn test scenario:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              // Test first notFound - should retry
              _handleNotFoundMessage(testCCCDName);
            },
            child: const Text('Test lần 1 (retry)'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // Simulate already tried once, test second notFound - should add to error
              _lastNotFoundCCCDName = testCCCDName;
              _hasTriedResend = true;
              _handleNotFoundMessage(testCCCDName);
            },
            child: const Text('Test lần 2 (add error)'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }

  // Firebase Key Management Methods
  void showFirebaseKeyDialog() {
    firebaseKeyController.text = currentFirebaseKey.value;

    Get.dialog(
      AlertDialog(
        title: const Text('Cấu hình Firebase Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Nhập key để liên kết với Chrome Extension và tránh xung đột với người dùng khác:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: firebaseKeyController,
              decoration: const InputDecoration(
                labelText: 'Firebase Key',
                hintText: 'Ví dụ: user123, room001, ...',
                border: OutlineInputBorder(),
              ),
              maxLength: 20,
            ),
            const SizedBox(height: 8),
            Text(
              'Key hiện tại: ${currentFirebaseKey.value.isEmpty ? "Chưa có" : currentFirebaseKey.value}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              clearFirebaseKey();
              Get.back();
            },
            child: const Text(
              'Xóa Key',
              style: TextStyle(color: Colors.red),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              saveFirebaseKey();
              Get.back();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void saveFirebaseKey() {
    final key = firebaseKeyController.text.trim();
    if (key.isEmpty) {
      showErrorMessage('Vui lòng nhập Firebase key');
      return;
    }

    // Validate key format (alphanumeric only)
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(key)) {
      showErrorMessage(
          'Key chỉ được chứa chữ cái, số, dấu gạch dưới và gạch ngang');
      return;
    }

    final firebaseManager = FirebaseManager();
    firebaseManager.currentKey = key;
    currentFirebaseKey.value = key;
    isKeySetupComplete.value = true;

    // Reset Firebase connection với key mới
    firebaseManager.resetConnection();

    showSuccessMessage('Đã lưu Firebase key: $key');
  }

  void clearFirebaseKey() {
    final firebaseManager = FirebaseManager();
    firebaseManager.currentKey = null;
    currentFirebaseKey.value = "";
    firebaseKeyController.clear();
    isKeySetupComplete.value = false;

    // Reset Firebase connection về mặc định
    firebaseManager.resetConnection();

    showInfoMessage('Đã xóa Firebase key');
  }

  String getFirebaseStatus() {
    if (currentFirebaseKey.value.isEmpty) {
      return 'Chưa cấu hình key';
    }
    return 'Key: ${currentFirebaseKey.value}';
  }
}
