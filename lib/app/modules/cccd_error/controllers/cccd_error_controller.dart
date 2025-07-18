import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../home/models/cccdInfo.dart';

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

  /// Copy all error CCCD data to clipboard
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

  /// Remove a CCCD from error list
  void removeErrorCCCD(int index) {
    if (index >= 0 && index < errorCCCDList.length) {
      final removedCCCD = errorCCCDList[index];
      errorCCCDList.removeAt(index);
      Get.snackbar(
          "Thông báo", "Đã xóa ${removedCCCD.Name} khỏi danh sách lỗi");
    }
  }

  /// Clear all error CCCDs
  void clearAllErrorCCCDs() {
    if (errorCCCDList.isEmpty) {
      Get.snackbar("Thông báo", "Danh sách lỗi đã trống");
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Xác nhận'),
        content: Text(
            'Bạn có chắc muốn xóa tất cả ${errorCCCDList.length} CCCD lỗi?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              errorCCCDList.clear();
              Get.back();
              Get.snackbar("Thành công", "Đã xóa tất cả CCCD lỗi");
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  /// Get Downloads directory with Android version compatibility
  Future<Directory?> _getDownloadsDirectory() async {
    try {
      if (Platform.isAndroid) {
        // For Android 10+ (API 29+), try to get Downloads directory
        // Note: getDownloadsDirectory() is available but may require special handling

        // Try to get external storage directory and navigate to Downloads
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          // Navigate to Downloads folder: /storage/emulated/0/Download
          const downloadsPath = '/storage/emulated/0/Download';
          final downloadsDir = Directory(downloadsPath);

          // Check if Downloads directory exists and is writable
          if (await downloadsDir.exists()) {
            // Test write permission by creating a temporary file
            try {
              final testFile = File(
                  '${downloadsDir.path}/.test_write_${DateTime.now().millisecondsSinceEpoch}');
              await testFile.writeAsString('test');
              await testFile.delete();
              return downloadsDir;
            } catch (e) {
              // No write permission to Downloads folder
              return null;
            }
          }
        }

        // Fallback: try getDownloadsDirectory() if available
        try {
          return await getDownloadsDirectory();
        } catch (e) {
          // getDownloadsDirectory() not available or failed
          return null;
        }
      }

      // For non-Android platforms, try getDownloadsDirectory()
      return await getDownloadsDirectory();
    } catch (e) {
      // All Downloads directory attempts failed
      return null;
    }
  }

  /// Show information dialog about file location and access
  void showFileLocationInfo() {
    Get.dialog(
      AlertDialog(
        title: const Text('Thông tin file Excel'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File Excel được lưu tại (theo thứ tự ưu tiên):'),
            SizedBox(height: 8),
            Text('1. Thư mục Downloads: /storage/emulated/0/Download/'),
            Text('2. Bộ nhớ ngoài: /Android/data/[app]/files/'),
            Text('3. Thư mục ứng dụng: /data/data/[app]/app_flutter/'),
            SizedBox(height: 12),
            Text('Để truy cập file:'),
            SizedBox(height: 8),
            Text('• Downloads: Mở ứng dụng "Downloads" hoặc "Files"'),
            Text(
                '• Bộ nhớ ngoài: Dùng file manager → Android/data/[app]/files/'),
            Text('• Thư mục ứng dụng: Dùng file manager với quyền root'),
            SizedBox(height: 12),
            Text('Mở file .xlsx bằng Excel, Google Sheets, hoặc WPS Office'),
            SizedBox(height: 8),
            Text(
                'Lưu ý: Ứng dụng sẽ tự động chọn vị trí tốt nhất dựa trên quyền truy cập và phiên bản Android.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
