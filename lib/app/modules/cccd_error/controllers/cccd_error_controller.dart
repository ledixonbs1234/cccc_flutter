import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../home/models/cccdInfo.dart';
import '../../home/controllers/home_controller.dart';
import '../../../managers/fireabaseManager.dart';

class CccdErrorController extends GetxController {
  final errorCCCDList = <CCCDInfo>[].obs;
  final isExporting = false.obs;
  final isLoading = false.obs;
  final totalCCCDList = <CCCDInfo>[].obs;
  final currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Load error CCCD list from Firebase on initialization
    loadErrorCCCDsFromFirebase();
  }

  /// Load all error CCCD data from Firebase Realtime Database
  Future<void> loadErrorCCCDsFromFirebase() async {
    isLoading.value = true;

    try {
      final snapshot =
          await FirebaseManager().rootPath.child('errorcccd').get();

      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

        // Get metadata if exists
        Map<dynamic, dynamic>? metadata =
            data['metadata'] as Map<dynamic, dynamic>?;
        Map<dynamic, dynamic>? records =
            data['records'] as Map<dynamic, dynamic>?;

        if (records != null) {
          List<CCCDInfo> loadedList = [];

          records.forEach((key, value) {
            try {
              Map<String, dynamic> recordMap =
                  Map<String, dynamic>.from(value as Map);
              // Create a new CCCDInfo instance and populate it using fromJson
              CCCDInfo cccd = CCCDInfo('', '', '');
              cccd.fromJson(recordMap);
              cccd.firebaseKey = key; // Store the Firebase key
              loadedList.add(cccd);
            } catch (e) {
              print('Error parsing CCCD record: $e');
            }
          });

          // Sort by errorIndex if available (stored in recordMap)
          loadedList.sort((a, b) {
            return a.index.compareTo(b.index);
          });

          errorCCCDList.value = loadedList;

          Get.snackbar(
            "Thành công",
            "Đã tải ${loadedList.length} bản ghi lỗi từ Firebase",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          errorCCCDList.clear();
          Get.snackbar(
            "Thông báo",
            "Không có dữ liệu lỗi trên Firebase",
            backgroundColor: Colors.grey,
            colorText: Colors.white,
          );
        }
      } else {
        errorCCCDList.clear();
        Get.snackbar(
          "Thông báo",
          "Không có dữ liệu lỗi trên Firebase",
          backgroundColor: Colors.grey,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Lỗi",
        "Không thể tải dữ liệu từ Firebase: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Copy all error CCCD data to clipboard (legacy method)
  void copyAllErrorCCCDData() {
    if (errorCCCDList.isEmpty) {
      Get.snackbar("Thông báo", "Không có dữ liệu lỗi để copy");
      return;
    }

    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < errorCCCDList.length; i++) {
      buffer.writeln(errorCCCDList[i].toCopyFormat(i + 1));
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    Get.snackbar("Thành công",
        "Đã copy ${errorCCCDList.length} bản ghi lỗi vào clipboard");
  }

  /// Check Firebase error records status
  Future<void> checkFirebaseErrorStatus() async {
    try {
      final snapshot = await FirebaseManager()
          .rootPath
          .child('errorcccd')
          .child('metadata')
          .get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> metadata =
            snapshot.value as Map<dynamic, dynamic>;
        String syncDate = metadata['syncDate'] ?? 'Unknown';
        int totalRecords = metadata['totalErrorRecords'] ?? 0;

        Get.snackbar(
          "Firebase Status",
          "Có $totalRecords bản ghi lỗi trên Firebase\nĐồng bộ lần cuối: ${syncDate.substring(0, 19)}",
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          "Firebase Status",
          "Không có dữ liệu lỗi nào trên Firebase",
          backgroundColor: Colors.grey,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Lỗi",
        "Không thể kiểm tra trạng thái Firebase: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Remove a CCCD from error list (local only)
  void removeErrorCCCD(int index) {
    if (index >= 0 && index < errorCCCDList.length) {
      final removedCCCD = errorCCCDList[index];
      errorCCCDList.removeAt(index);

      Get.snackbar(
        "Thông báo",
        "Đã xóa ${removedCCCD.Name} khỏi danh sách lỗi (chỉ local)",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  /// Get the position of a CCCD in the total list (1-based index)
  int getPositionInTotalList(CCCDInfo cccd) {
    if (totalCCCDList.isEmpty) return -1;

    int position = totalCCCDList.indexWhere((item) => item.Id == cccd.Id);
    return position != -1 ? position + 1 : -1;
  }

  /// Get total count of CCCDs in the main list
  int getTotalCCCDCount() {
    return totalCCCDList.length;
  }

  /// Clear all error CCCDs from local list only (does not modify Firebase)
  void clearAllErrorCCCDs() {
    if (errorCCCDList.isEmpty) {
      Get.snackbar("Thông báo", "Danh sách lỗi đã trống");
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Xác nhận'),
        content: Text(
            'Bạn có chắc muốn xóa tất cả ${errorCCCDList.length} CCCD lỗi khỏi danh sách local?\n\nLưu ý: Dữ liệu trên Firebase sẽ không bị xóa. Bạn có thể tải lại bằng nút "Tải lại từ Firebase".'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              // Clear local list only
              int count = errorCCCDList.length;
              errorCCCDList.clear();

              Get.back();
              Get.snackbar(
                "Thành công",
                "Đã xóa $count CCCD lỗi khỏi danh sách local",
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}
