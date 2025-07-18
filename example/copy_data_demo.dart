// Demo showing copy data functionality
// This demonstrates how the copy feature works with sample CCCD data

import '../lib/app/modules/home/controllers/home_controller.dart';
import '../lib/app/modules/home/models/cccdInfo.dart';

void main() {
  // Create a controller instance
  final controller = HomeController();

  // Add sample CCCD data matching the format you provided
  List<Map<String, String>> sampleData = [
    {
      'id': '093211007653',
      'name': 'Trình Quốc Hưng',
      'birth': '19/03/2011',
      'gender': 'Nam',
      'address': 'Diễn Khánh Hoài Đức'
    },
    {
      'id': '052220000970',
      'name': 'Lê Phước Đạt',
      'birth': '22/01/2020',
      'gender': 'Nam',
      'address': 'Khu Phố 6 Bồng Sơn'
    },
    {
      'id': '052323003753',
      'name': 'Trần La An Ha',
      'birth': '10/05/2023',
      'gender': 'Nữ',
      'address': 'Thiện Đức Hoài Hương'
    },
    {
      'id': '052224009718',
      'name': 'Lê Phước Khải',
      'birth': '23/10/2024',
      'gender': 'Nam',
      'address': 'Khu Phố 6 Bồng Sơn'
    },
    {
      'id': '052320009083',
      'name': 'Lê Trương Thiên Kim',
      'birth': '09/10/2020',
      'gender': 'Nữ',
      'address': 'An Sơn Hoài Châu'
    },
    {
      'id': '052221003482',
      'name': 'Nguyễn Ngọc Huy',
      'birth': '03/05/2021',
      'gender': 'Nam',
      'address': 'Túy Thạnh Hoài Sơn'
    },
    {
      'id': '052224008765',
      'name': 'Phạm Thành Đạt',
      'birth': '05/10/2024',
      'gender': 'Nam',
      'address': 'Tài Lương 4 Hoài Thanh Tây'
    },
    {
      'id': '052221012922',
      'name': 'Võ Hoàng Minh Thiên',
      'birth': '14/06/2021',
      'gender': 'Nam',
      'address': 'Định Bình Nam Hoài Đức'
    },
    {
      'id': '052322003745',
      'name': 'Từ Phạm Diễm My',
      'birth': '20/05/2022',
      'gender': 'Nữ',
      'address': 'An Dưỡng 1 Hoài Tân'
    },
    {
      'id': '052219013704',
      'name': 'Nguyễn Đặng Bảo Khang',
      'birth': '28/07/2019',
      'gender': 'Nam',
      'address': 'An Dưỡng 1 Hoài Tân'
    }
  ];

  // Add sample data to controller
  for (var data in sampleData) {
    CCCDInfo cccdInfo = CCCDInfo(data['name']!, data['birth']!, data['id']!);
    cccdInfo.gioiTinh = data['gender']!;
    cccdInfo.DiaChi = data['address']!;
    controller.totalCCCD.add(cccdInfo);
  }

  print('=== DEMO: Copy Data Functionality ===');
  print('Total CCCD records: ${controller.totalCCCD.length}');
  print('');

  // Simulate the copy functionality
  print('=== Formatted Copy Data ===');
  StringBuffer buffer = StringBuffer();
  for (int i = 0; i < controller.totalCCCD.length; i++) {
    String line = controller.totalCCCD[i].toCopyFormat(i + 1);
    buffer.writeln(line);
    print(line);
  }

  print('');
  print('=== Copy Data Summary ===');
  print('Format: [Index]\\t[ID]\\t[Name]\\t[Birth Date]\\t[Gender]\\t[Address]');
  print('Total characters: ${buffer.toString().length}');
  print('Ready to copy to clipboard!');

  // Test individual record formatting
  print('');
  print('=== Individual Record Test ===');
  CCCDInfo testRecord = controller.totalCCCD.first;
  print('Original data:');
  print('  Name: ${testRecord.Name}');
  print('  ID: ${testRecord.Id}');
  print('  Birth: ${testRecord.NgaySinh}');
  print('  Gender: ${testRecord.gioiTinh}');
  print('  Address: ${testRecord.DiaChi}');
  print('');
  print('Formatted for copy:');
  print('  ${testRecord.toCopyFormat(1)}');
}
