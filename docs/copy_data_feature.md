# Tính năng Copy Dữ liệu CCCD

## Tổng quan
Tính năng Copy Dữ liệu cho phép người dùng sao chép tất cả thông tin CCCD đã quét theo định dạng tab-separated values (TSV) để dễ dàng paste vào Excel, Google Sheets hoặc các ứng dụng khác.

## Định dạng dữ liệu
Mỗi bản ghi CCCD được format theo cấu trúc:
```
[STT]	[Số CCCD]	[Họ tên]	[Ngày sinh]	[Giới tính]	[Địa chỉ]
```

### Ví dụ:
```
1	093211007653	Trình Quốc Hưng	19/03/2011	Nam	Diễn Khánh Hoài Đức
2	052220000970	Lê Phước Đạt	22/01/2020	Nam	Khu Phố 6 Bồng Sơn
3	052323003753	Trần La An Ha	10/05/2023	Nữ	Thiện Đức Hoài Hương
```

## Cách sử dụng

### 1. Trong ứng dụng
1. Quét các CCCD cần thiết bằng chức năng "Capture"
2. Bật chế độ "Tự động chạy" để tích lũy dữ liệu
3. Nhấn button **"Copy Data"** (màu xanh lá) để copy tất cả dữ liệu
4. Paste vào ứng dụng đích (Excel, Google Sheets, v.v.)

### 2. Vị trí button
Button "Copy Data" được đặt cạnh button "Capture" ở phần đầu màn hình, có:
- Icon: 📋 (copy)
- Màu: Xanh lá cây
- Text: "Copy Data"

### 3. Thông báo
- **Thành công**: "Đã copy [số lượng] bản ghi vào clipboard"
- **Không có dữ liệu**: "Không có dữ liệu để copy"

## Cấu trúc dữ liệu

### Model CCCDInfo đã được cập nhật:
```dart
class CCCDInfo {
  late String Name;        // Họ tên
  late String Id;          // Số CCCD
  late String NgaySinh;    // Ngày sinh (dd/MM/yyyy)
  late String DiaChi;      // Địa chỉ
  late String NgayLamCCCD; // Ngày làm CCCD
  late String TimeStamp;   // Thời gian tạo
  late String gioiTinh;    // Giới tính (Nam/Nữ)
  
  // Method tạo chuỗi copy
  String toCopyFormat(int index) {
    return "$index\t$Id\t$Name\t$NgaySinh\t$gioiTinh\t$DiaChi";
  }
}
```

### Controller method:
```dart
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
  Get.snackbar("Thành công", "Đã copy ${totalCCCD.length} bản ghi vào clipboard");
}
```

## Xử lý dữ liệu từ barcode

### Cấu trúc barcode CCCD:
```
[ID]|[Trống]|[Họ tên]|[Ngày sinh]|[Giới tính]|[Địa chỉ]|[Ngày làm CCCD]|[Trống]|[Tên cha]|[Tên mẹ]|[Trống]
```

### Logic xử lý:
- **Giới tính**: Lấy từ `textSplit[4]` nếu có
- **Địa chỉ**: 
  - Với mảng 11 phần tử: `textSplit[5]`
  - Với mảng 7 phần tử: `textSplit[5]`
- **Ngày sinh**: Format từ `DDMMYYYY` thành `DD/MM/YYYY`

## Tính năng bổ sung

### 1. Tìm kiếm CCCD
- Hỗ trợ tìm kiếm không dấu cho tiếng Việt
- Ví dụ: Tìm "Ngoc" sẽ tìm thấy "Ngọc"

### 2. Tự động cuộn
- Tự động cuộn đến bản ghi được tìm thấy
- Hiệu ứng cuộn mượt mà

### 3. Validation
- Kiểm tra dữ liệu trước khi copy
- Thông báo lỗi nếu không có dữ liệu

## Testing

### Unit Tests
File: `test/copy_data_test.dart`
- Test format dữ liệu đơn lẻ
- Test format nhiều bản ghi
- Test xử lý dữ liệu từ barcode
- Test format ngày tháng

### Demo
File: `example/simple_copy_demo.dart`
- Demo chức năng copy với dữ liệu mẫu
- Kiểm tra format output
- So sánh với format mong đợi

## Lưu ý kỹ thuật

### 1. Dependencies
- `flutter/services.dart`: Cho Clipboard
- `get/get.dart`: Cho thông báo

### 2. Performance
- Sử dụng StringBuffer cho hiệu suất tốt khi nối chuỗi
- Lazy loading cho danh sách lớn

### 3. Error Handling
- Kiểm tra danh sách rỗng
- Xử lý exception khi copy vào clipboard
- Thông báo lỗi thân thiện với người dùng

## Tương lai

### Tính năng có thể mở rộng:
1. **Export to file**: Xuất ra file CSV/Excel
2. **Custom format**: Cho phép người dùng tùy chỉnh format
3. **Selective copy**: Copy chỉ những bản ghi được chọn
4. **Copy individual**: Copy từng bản ghi riêng lẻ
5. **Template support**: Hỗ trợ nhiều template khác nhau
