# NotFound Retry Logic Implementation

## Mô tả
Triển khai logic xử lý thông báo "notFound" với cơ chế retry và auto-add to error list.

## Yêu cầu ban đầu
- **Lần đầu tiên** nhận message `notFound`: Gửi lại CCCD hiện tại
- **Lần thứ hai** nhận message `notFound` với cùng `DoiTuong`: Thêm vào danh sách lỗi

## Implementation Chi tiết

### 1. Thêm biến tracking trong HomeController

```dart
// NotFound retry tracking
String? _lastNotFoundCCCDName;
bool _hasTriedResend = false;
```

### 2. Sửa đổi logic xử lý message trong `onListenNotification`

**Trước:**
```dart
} else if (message.Lenh == "notFound") {
  showErrorMessage("Không tìm thấy CCCD tên ${message.DoiTuong}");
```

**Sau:**
```dart
} else if (message.Lenh == "notFound") {
  _handleNotFoundMessage(message.DoiTuong);
```

### 3. Thêm method `_handleNotFoundMessage`

```dart
void _handleNotFoundMessage(String cccdName) {
  if (_lastNotFoundCCCDName == cccdName && _hasTriedResend) {
    // Lần thứ 2 - thêm vào danh sách lỗi
    showErrorMessage("CCCD $cccdName không tìm thấy sau 2 lần thử - đã thêm vào danh sách lỗi");
    addCurrentCCCDToError();
    _resetNotFoundTracking();
  } else {
    // Lần đầu - thử gửi lại
    _lastNotFoundCCCDName = cccdName;
    _hasTriedResend = true;
    
    showWarningMessage("Không tìm thấy CCCD $cccdName - đang thử gửi lại");
    
    // Resend current CCCD
    isSending = false;
    if (isAutoRun.value) {
      processCCCD();
    }
  }
}
```

### 4. Reset tracking khi cần thiết

**Khi xử lý CCCD mới (`processCCCD`):**
```dart
// Reset notFound tracking when processing new CCCD
_resetNotFoundTracking();
```

**Khi nhận được thông báo thành công (`continueCCCD`):**
```dart
// Reset notFound tracking on successful processing
_resetNotFoundTracking();
```

### 5. Thêm method test để kiểm tra logic

```dart
void testNotFoundRetryLogic() {
  // Test method với dialog cho phép test 2 scenarios
}
```

### 6. Thêm UI button test

Thêm button "Test NotFound" trong UI để test logic này.

## Flow Logic

```
1. Nhận message "notFound" với tên CCCD X
   ↓
2. Check: Đã từng nhận "notFound" cho CCCD X chưa?
   ↓
   NO: Lần đầu tiên
   - Lưu tên CCCD X
   - Đánh dấu đã thử resend
   - Gửi lại CCCD
   ↓
   YES: Lần thứ 2
   - Thêm CCCD hiện tại vào danh sách lỗi
   - Reset tracking
   - Chuyển sang CCCD tiếp theo

3. Reset tracking khi:
   - Bắt đầu xử lý CCCD mới
   - Nhận được thông báo thành công
```

## Test Cases

### Test Case 1: Lần đầu nhận notFound
1. Bật auto run
2. Click "Test NotFound" → "Test lần 1"
3. **Expected**: Hiển thị warning message và resend

### Test Case 2: Lần thứ 2 nhận notFound
1. Bật auto run  
2. Click "Test NotFound" → "Test lần 2"
3. **Expected**: Thêm vào danh sách lỗi và chuyển CCCD tiếp theo

## Files Modified

1. `lib/app/modules/home/controllers/home_controller.dart`
   - Thêm biến tracking
   - Thêm `_handleNotFoundMessage()` method
   - Thêm `_resetNotFoundTracking()` method
   - Sửa đổi `onListenNotification()`
   - Thêm reset trong `processCCCD()` và message "continueCCCD"
   - Thêm `testNotFoundRetryLogic()` method

2. `lib/app/modules/home/views/home_view.dart`
   - Thêm button "Test NotFound" trong UI

3. `docs/notfound_retry_implementation.md` (mới)
   - Tài liệu implementation này

## Lưu ý

- Logic chỉ hoạt động khi `isAutoRun.value == true`
- Tracking được reset khi chuyển sang CCCD khác hoặc khi thành công
- Method test giúp kiểm tra logic mà không cần thực sự gửi request
- Error handling an toàn, không ảnh hưởng đến flow chính
