import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import '../lib/app/modules/home/controllers/home_controller.dart';
import '../lib/app/modules/home/models/cccdInfo.dart';

void main() {
  group('Copy Data Tests', () {
    late HomeController controller;

    setUp(() {
      Get.testMode = true;
      controller = HomeController();
      Get.put(controller);
    });

    tearDown(() {
      Get.reset();
    });

    test('toCopyFormat should return correct format', () {
      // Arrange
      CCCDInfo cccdInfo =
          CCCDInfo('Trình Quốc Hưng', '19/03/2011', '093211007653');
      cccdInfo.gioiTinh = 'Nam';
      cccdInfo.DiaChi = 'Diễn Khánh Hoài Đức';

      // Act
      String result = cccdInfo.toCopyFormat(1);

      // Assert
      expect(result,
          '1\t093211007653\tTrình Quốc Hưng\t19/03/2011\tNam\tDiễn Khánh Hoài Đức');
    });

    test('copyAllCCCDData should format multiple records correctly', () {
      // Arrange
      List<Map<String, String>> testData = [
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
        }
      ];

      // Add test data to controller
      for (var data in testData) {
        CCCDInfo cccdInfo =
            CCCDInfo(data['name']!, data['birth']!, data['id']!);
        cccdInfo.gioiTinh = data['gender']!;
        cccdInfo.DiaChi = data['address']!;
        controller.totalCCCD.add(cccdInfo);
      }

      // Act - We can't actually test clipboard functionality in unit tests
      // but we can test the data formatting logic
      StringBuffer buffer = StringBuffer();
      for (int i = 0; i < controller.totalCCCD.length; i++) {
        buffer.writeln(controller.totalCCCD[i].toCopyFormat(i + 1));
      }
      String result = buffer.toString();

      // Assert
      List<String> lines = result.trim().split('\n');
      expect(lines.length, 3);
      expect(lines[0],
          '1\t093211007653\tTrình Quốc Hưng\t19/03/2011\tNam\tDiễn Khánh Hoài Đức');
      expect(lines[1],
          '2\t052220000970\tLê Phước Đạt\t22/01/2020\tNam\tKhu Phố 6 Bồng Sơn');
      expect(lines[2],
          '3\t052323003753\tTrần La An Ha\t10/05/2023\tNữ\tThiện Đức Hoài Hương');
    });

    test('formatDateString should work correctly', () {
      // Act & Assert
      expect(controller.formatDateString('19032011'), '19/03/2011');
      expect(controller.formatDateString('22012020'), '22/01/2020');
      expect(controller.formatDateString('10052023'), '10/05/2023');
    });

    test('CCCDInfo should handle gender correctly from barcode data', () {
      // Simulate barcode data parsing
      String barcodeFilled =
          "052321010762||Dương Lê Như Ngọc|20112021|Nữ|Tổ 7, Khu Phố Thiện Đức Bắc, Hoài Hương, Hoài Nhơn, Bình Định|06112024||Dương Văn Thông|Lê Thị Bích Nhiên|";
      List<String> textSplit = barcodeFilled.split('|');

      // Create CCCDInfo as the controller would
      CCCDInfo cccdInfo = CCCDInfo(textSplit[2],
          controller.formatDateString(textSplit[3]), textSplit[0]);
      if (textSplit.length >= 5) {
        cccdInfo.gioiTinh = textSplit[4];
      }
      // For 11-element array, address is at index 5
      cccdInfo.DiaChi = textSplit.length == 11
          ? textSplit[5]
          : (textSplit.length == 7 ? textSplit[5] : "");

      // Assert
      expect(cccdInfo.Name, 'Dương Lê Như Ngọc');
      expect(cccdInfo.Id, '052321010762');
      expect(cccdInfo.NgaySinh, '20/11/2021');
      expect(cccdInfo.gioiTinh, 'Nữ');
      expect(cccdInfo.DiaChi,
          'Tổ 7, Khu Phố Thiện Đức Bắc, Hoài Hương, Hoài Nhơn, Bình Định');
    });
  });
}
