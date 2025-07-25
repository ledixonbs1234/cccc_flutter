import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../home/models/cccdInfo.dart';
import '../../../managers/fireabaseManager.dart';

class CccdErrorController extends GetxController {
  final errorCCCDList = <CCCDInfo>[].obs;
  final isExporting = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Get error CCCD list from arguments if passed
    if (Get.arguments != null && Get.arguments is List<CCCDInfo>) {
      errorCCCDList.value = Get.arguments as List<CCCDInfo>;
    }
  }

  /// Sync all error CCCD data to Firebase Realtime Database
  /// (Optimized for a single write operation)
  Future<void> syncErrorCCCDsToFirebase() async {
    if (errorCCCDList.isEmpty) {
      Get.snackbar("Thông báo", "Không có dữ liệu lỗi để đồng bộ");
      return;
    }

    try {
      // Chuẩn bị một Map để chứa tất cả các bản ghi lỗi.
      // Các key của map này sẽ là các ID duy nhất được tạo bởi push().key.
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

        // Tạo một key duy nhất cho mỗi bản ghi mà không ghi dữ liệu
        String? uniqueKey = recordsRef.push().key;
        if (uniqueKey != null) {
          recordsMap[uniqueKey] = errorRecord;
        }
      }

      // Chuẩn bị toàn bộ payload để ghi một lần
      Map<String, dynamic> finalPayload = {
        'metadata': {
          'totalErrorRecords': errorCCCDList.length,
          'syncTimestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'syncDate': DateTime.now().toIso8601String(),
        },
        // Thêm tất cả các bản ghi lỗi đã chuẩn bị
        'records': recordsMap,
      };

      // Thực hiện ghi toàn bộ dữ liệu lên node 'errorcccd' trong một thao tác duy nhất
      await FirebaseManager().rootPath.child('errorcccd').set(finalPayload);

      Get.snackbar(
        "Thành công",
        "Đã đồng bộ ${errorCCCDList.length} bản ghi lỗi lên Firebase",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Lỗi",
        "Không thể đồng bộ dữ liệu lên Firebase: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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

  /// Remove a CCCD from error list
  void removeErrorCCCD(int index) {
    if (index >= 0 && index < errorCCCDList.length) {
      final removedCCCD = errorCCCDList[index];
      errorCCCDList.removeAt(index);
      Get.snackbar(
          "Thông báo", "Đã xóa ${removedCCCD.Name} khỏi danh sách lỗi");
    }
  }

  /// Clear all error CCCDs from local list and Firebase
  void clearAllErrorCCCDs() {
    if (errorCCCDList.isEmpty) {
      Get.snackbar("Thông báo", "Danh sách lỗi đã trống");
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Xác nhận'),
        content: Text(
            'Bạn có chắc muốn xóa tất cả ${errorCCCDList.length} CCCD lỗi?\nDữ liệu sẽ được xóa cả trên thiết bị và Firebase.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Clear from Firebase first
                await FirebaseManager().rootPath.child('errorcccd').remove();

                // Clear local list
                errorCCCDList.clear();

                Get.back();
                Get.snackbar(
                  "Thành công",
                  "Đã xóa tất cả CCCD lỗi khỏi thiết bị và Firebase",
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                // If Firebase fails, still clear local list
                errorCCCDList.clear();
                Get.back();
                Get.snackbar(
                  "Cảnh báo",
                  "Đã xóa dữ liệu cục bộ nhưng có lỗi khi xóa Firebase: $e",
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
