import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../services/vnpost_service.dart';
import '../../../services/vnpost_html_parser.dart';
import '../models/vnpost_transaction.dart';

class TimKiemController extends GetxController {
  // Text controllers
  final nameController = TextEditingController();
  final birthDateController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // Raw birth date input (only numbers)
  String _rawBirthDate = '';

  // Observable variables
  final selectedMonth = 0.obs;
  final webSearchResults = <VNPostTransaction>[].obs;
  final isSearching = false.obs;
  final isLoggingIn = false.obs;
  final isAccountCardExpanded = false.obs;

  final isPasswordVisible = false.obs;

  // Storage for credentials
  final _storage = GetStorage();
  final String _usernameKey = 'vnpost_username';
  final String _passwordKey = 'vnpost_password';
  final userCurrent = ''.obs;
  final passwordCurrent = ''.obs;

  // VNPost service
  final VNPostService _vnPostService = VNPostService();

  // Date picker
  DateTime? selectedDate;

  @override
  void onInit() {
    super.onInit();
    // Set default month to current month
    selectedMonth.value = DateTime.now().month;
    // Load saved credentials
    _loadCredentials();

    // Listen to birth date changes for auto-formatting
    birthDateController.addListener(_onBirthDateChanged);
  }

  // Auto-format birth date as user types
  void _onBirthDateChanged() {
    final text = birthDateController.text;
    final cursorPosition = birthDateController.selection.baseOffset;

    // Remove all non-digit characters
    final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');

    // Only update if the digits changed
    if (digitsOnly != _rawBirthDate) {
      _rawBirthDate = digitsOnly;

      // Format the date
      String formatted = _formatBirthDate(digitsOnly);

      // Calculate new cursor position
      int newCursorPos = formatted.length;
      if (cursorPosition >= 0 && cursorPosition <= text.length) {
        // Count digits before cursor in old text
        final digitsBeforeCursor = text
            .substring(0, cursorPosition)
            .replaceAll(RegExp(r'[^\d]'), '')
            .length;

        // Find position in new formatted text
        int digitCount = 0;
        for (int i = 0; i < formatted.length; i++) {
          if (RegExp(r'\d').hasMatch(formatted[i])) {
            digitCount++;
          }
          if (digitCount >= digitsBeforeCursor) {
            newCursorPos = i + 1;
            break;
          }
        }
      }

      // Update text field
      birthDateController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: newCursorPos),
      );
    }
  }

  // Format birth date with slashes: DD/MM/YYYY
  String _formatBirthDate(String digits) {
    if (digits.isEmpty) return '';

    String formatted = '';

    // Add day (max 2 digits)
    if (digits.length >= 1) {
      formatted += digits.substring(0, digits.length >= 2 ? 2 : 1);
    }

    // Add slash and month
    if (digits.length >= 3) {
      formatted += '/${digits.substring(2, digits.length >= 4 ? 4 : 3)}';
    }

    // Add slash and year
    if (digits.length >= 5) {
      formatted +=
          '/${digits.substring(4, digits.length > 8 ? 8 : digits.length)}';
    }

    return formatted;
  }

  @override
  void onClose() {
    birthDateController.removeListener(_onBirthDateChanged);
    nameController.dispose();
    birthDateController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Load saved credentials from storage
  void _loadCredentials() {
    final username = _storage.read(_usernameKey);
    final password = _storage.read(_passwordKey);
    userCurrent.value = username ?? '';
    passwordCurrent.value = password ?? '';

    // if (username != null) {
    //   usernameController.text = username;
    // }
    // if (password != null) {
    //   passwordController.text = password;
    // }
  }

  // Save credentials to storage
  void saveCredentials() {
    _storage.write(_usernameKey, usernameController.text);
    _storage.write(_passwordKey, passwordController.text);
    userCurrent.value = usernameController.text;
    passwordCurrent.value = passwordController.text;

    Get.snackbar(
      'Đã lưu',
      'Thông tin tài khoản đã được lưu',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  // Toggle account card visibility
  void toggleAccountCard() {
    isAccountCardExpanded.value = !isAccountCardExpanded.value;
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Clear birth date field
  void clearBirthDate() {
    _rawBirthDate = '';
    birthDateController.clear();
    selectedDate = null;
  }

  // Method to perform web search on VNPost
  Future<void> performWebSearch() async {
    if (nameController.text.isEmpty || nameController.text.trim().length < 5) {
      Get.snackbar(
        'Thông báo',
        'Vui lòng nhập họ tên để tìm kiếm',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Check if credentials are provided
    if (userCurrent.value.isEmpty || passwordCurrent.value.isEmpty) {
      Get.snackbar(
        'Thiếu thông tin',
        'Vui lòng nhập tài khoản và mật khẩu VNPost',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      isAccountCardExpanded.value = true; // Show account card
      return;
    }

    isSearching.value = true;

    try {
      // Prepare search parameters
      // Birth date is already in DD/MM/YYYY format from auto-formatting
      final ngaySinh =
          birthDateController.text.isNotEmpty ? birthDateController.text : null;

      // Calculate date range based on selected month
      final now = DateTime.now();
      final currentYear = now.year;
      final searchMonth =
          selectedMonth.value > 0 ? selectedMonth.value : now.month;

      // Start date: 1st of selected month
      final ngayBatDau =
          _formatDateForWeb(DateTime(currentYear, searchMonth, 1));

      // End date: last day of month + 2 months OR current date (if selected month is current month)
      DateTime endDate;
      if (searchMonth == now.month && currentYear == now.year) {
        // If searching current month, end date is today + 2 months
        endDate = DateTime(now.year, now.month + 2, now.day);
      } else {
        // Otherwise, end date is last day of the selected month + 2 months
        endDate = DateTime(currentYear, searchMonth + 3,
            0); // +3 months then day 0 = last day of (month+2)
      }
      final ngayKetThuc = _formatDateForWeb(endDate);

      // Attempt search
      var result = await _vnPostService.search(
        hoTen: nameController.text,
        ngaySinh: ngaySinh,
        ngayBatDau: ngayBatDau,
        ngayKetThuc: ngayKetThuc,
      );

      // If needs login, attempt login and retry
      if (result.needsLogin) {
        // Perform login with user credentials
        isLoggingIn.value = true;
        Get.snackbar(
          'Đang đăng nhập',
          'Đang đăng nhập vào VNPost...',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        final loginSuccess = await _vnPostService.login(
          username: userCurrent.value,
          password: passwordCurrent.value,
        );

        isLoggingIn.value = false;

        if (loginSuccess) {
          Get.snackbar(
            'Đăng nhập thành công',
            'Đang thực hiện tìm kiếm...',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );

          // Retry search after login
          result = await _vnPostService.search(
            hoTen: nameController.text,
            ngaySinh: ngaySinh,
            ngayBatDau: ngayBatDau,
            ngayKetThuc: ngayKetThuc,
          );
        } else {
          Get.snackbar(
            'Đăng nhập thất bại',
            'Không thể đăng nhập vào VNPost',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          isSearching.value = false;
          return;
        }
      }

      // Process result
      if (result.success) {
        // Parse HTML to extract transaction data
        final transactions =
            VNPostHtmlParser.parseTransactions(result.htmlResponse);
        webSearchResults.value = transactions;

        if (transactions.isEmpty) {
          Get.snackbar(
            'Không tìm thấy',
            'Không có giao dịch nào phù hợp với tiêu chí tìm kiếm',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        } else {
          Get.snackbar(
            'Tìm kiếm thành công',
            'Tìm thấy ${transactions.length} giao dịch',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }
      } else {
        Get.snackbar(
          'Lỗi tìm kiếm',
          'Không thể tìm kiếm trên VNPost. Mã lỗi: ${result.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể kết nối tới VNPost: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSearching.value = false;
    }
  }

  // Copy postal code to clipboard
  void copyPostalCode(String postalCode) {
    Clipboard.setData(ClipboardData(text: postalCode));
    Get.snackbar(
      'Đã sao chép',
      'Mã bưu gửi $postalCode đã được sao chép',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  // Format date for web (dd/MM/yyyy)
  String _formatDateForWeb(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  // Method to clear search
  void clearSearch() {
    nameController.clear();
    clearBirthDate();
    selectedMonth.value = DateTime.now().month;
    webSearchResults.clear();
  }

  // Get month name in Vietnamese
  String getMonthName(int month) {
    const months = [
      'Tất cả',
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];
    return months[month];
  }
}
