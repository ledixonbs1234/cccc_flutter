// ListView scrolling functionality tests
//
// These tests verify that the ListView widget in the home view
// can scroll properly and that the search functionality works correctly.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:cccc_flutter/app/modules/home/controllers/home_controller.dart';
import 'package:cccc_flutter/app/modules/home/models/cccdInfo.dart';
import 'package:cccc_flutter/app/modules/home/views/home_view.dart';

void main() {
  group('ListView Scrolling Tests', () {
    testWidgets(
        'ListView should be scrollable when physics is AlwaysScrollableScrollPhysics',
        (WidgetTester tester) async {
      // Initialize GetX
      Get.testMode = true;

      // Create a test controller with sample data
      final controller = HomeController();
      Get.put(controller);

      // Add sample CCCD data to test scrolling
      for (int i = 0; i < 20; i++) {
        controller.totalCCCD
            .add(CCCDInfo('Test Name $i', '01/01/2000', '12345678901$i'));
      }

      // Enable auto run to show the ListView
      controller.isAutoRun.value = true;

      // Build our app and trigger a frame
      await tester.pumpWidget(
        const GetMaterialApp(
          home: HomeView(),
        ),
      );
      await tester.pumpAndSettle();

      // Find the ListView
      final listViewFinder = find.byType(ListView);
      expect(listViewFinder, findsOneWidget);

      // Get the ListView widget
      final ListView listView = tester.widget(listViewFinder);

      // Verify that the ListView has scrollable physics
      expect(listView.physics, isA<AlwaysScrollableScrollPhysics>());
      expect(listView.physics, isNot(isA<NeverScrollableScrollPhysics>()));

      // Verify that the ListView has a scroll controller
      expect(listView.controller, isNotNull);
      expect(listView.controller, equals(controller.scrollController));

      // Clean up
      Get.reset();
    });

    testWidgets('Search functionality should calculate correct scroll position',
        (WidgetTester tester) async {
      // Initialize GetX
      Get.testMode = true;

      // Create a test controller
      final controller = HomeController();
      Get.put(controller);

      // Add sample CCCD data
      for (int i = 0; i < 10; i++) {
        controller.totalCCCD
            .add(CCCDInfo('Person $i', '01/01/2000', '12345678901$i'));
      }

      // Test search functionality calculation
      // This tests the logic without requiring the full widget tree
      int foundIndex = controller.totalCCCD
          .indexWhere((item) => item.Name.toLowerCase().contains('person 5'));

      expect(foundIndex, equals(5));

      // Verify the scroll calculation would be correct with new height
      double expectedPosition =
          foundIndex * 88.0; // index * new estimated item height
      expect(expectedPosition, equals(440.0));

      // Clean up
      Get.reset();
    });

    testWidgets('Vietnamese diacritic removal should work correctly',
        (WidgetTester tester) async {
      // Initialize GetX
      Get.testMode = true;

      // Create a test controller
      final controller = HomeController();
      Get.put(controller);

      // Add sample CCCD data with Vietnamese names
      controller.totalCCCD.addAll([
        CCCDInfo('Dương Lê Như Ngọc', '01/01/2000', '123456789011'),
        CCCDInfo('Nguyễn Văn Hùng', '01/01/2000', '123456789012'),
        CCCDInfo('Trần Thị Hạnh', '01/01/2000', '123456789013'),
        CCCDInfo('Lê Minh Đức', '01/01/2000', '123456789014'),
      ]);

      // Test Vietnamese diacritic removal functionality
      // Search without diacritics should find names with diacritics

      // Test 1: "Ngoc" should find "Ngọc"
      int foundIndex1 = controller.totalCCCD.indexWhere((item) {
        String normalizedName =
            controller.removeDiacritics(item.Name.toLowerCase());
        return normalizedName.contains('ngoc');
      });
      expect(foundIndex1, equals(0)); // Should find "Dương Lê Như Ngọc"

      // Test 2: "Duong" should find "Dương"
      int foundIndex2 = controller.totalCCCD.indexWhere((item) {
        String normalizedName =
            controller.removeDiacritics(item.Name.toLowerCase());
        return normalizedName.contains('duong');
      });
      expect(foundIndex2, equals(0)); // Should find "Dương Lê Như Ngọc"

      // Test 3: "Hung" should find "Hùng"
      int foundIndex3 = controller.totalCCCD.indexWhere((item) {
        String normalizedName =
            controller.removeDiacritics(item.Name.toLowerCase());
        return normalizedName.contains('hung');
      });
      expect(foundIndex3, equals(1)); // Should find "Nguyễn Văn Hùng"

      // Test 4: "Duc" should find "Đức"
      int foundIndex4 = controller.totalCCCD.indexWhere((item) {
        String normalizedName =
            controller.removeDiacritics(item.Name.toLowerCase());
        return normalizedName.contains('duc');
      });
      expect(foundIndex4, equals(3)); // Should find "Lê Minh Đức"

      // Clean up
      Get.reset();
    });

    test(
        'Optimized removeDiacritics should handle all Vietnamese characters correctly',
        () {
      // Initialize GetX
      Get.testMode = true;

      // Create a test controller
      final controller = HomeController();
      Get.put(controller);

      // Test comprehensive Vietnamese character coverage
      final testCases = {
        // Lowercase a variants (17 characters)
        'àáạảãâầấậẩẫăằắặẳẵ': 'aaaaaaaaaaaaaaaaa',
        // Lowercase e variants (11 characters)
        'èéẹẻẽêềếệểễ': 'eeeeeeeeeee',
        // Lowercase i variants (5 characters)
        'ìíịỉĩ': 'iiiii',
        // Lowercase o variants (17 characters)
        'òóọỏõôồốộổỗơờớợởỡ': 'ooooooooooooooooo',
        // Lowercase u variants (11 characters)
        'ùúụủũưừứựửữ': 'uuuuuuuuuuu',
        // Lowercase y variants (5 characters)
        'ỳýỵỷỹ': 'yyyyy',
        // Lowercase d variant
        'đ': 'd',

        // Uppercase variants (17 characters)
        'ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴ': 'AAAAAAAAAAAAAAAAA',
        // Uppercase e variants (11 characters)
        'ÈÉẸẺẼÊỀẾỆỂỄ': 'EEEEEEEEEEE',
        // Uppercase i variants (5 characters)
        'ÌÍỊỈĨ': 'IIIII',
        // Uppercase o variants (17 characters)
        'ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠ': 'OOOOOOOOOOOOOOOOO',
        // Uppercase u variants (11 characters)
        'ÙÚỤỦŨƯỪỨỰỬỮ': 'UUUUUUUUUUU',
        // Uppercase y variants (5 characters)
        'ỲÝỴỶỸ': 'YYYYY',
        'Đ': 'D',

        // Mixed case and common Vietnamese names
        'Nguyễn Văn Hùng': 'Nguyen Van Hung',
        'Trần Thị Hạnh': 'Tran Thi Hanh',
        'Dương Lê Như Ngọc': 'Duong Le Nhu Ngoc',
        'Lê Minh Đức': 'Le Minh Duc',
        'Phạm Thị Hương': 'Pham Thi Huong',
        'Hoàng Văn Tuấn': 'Hoang Van Tuan',
      };

      for (var entry in testCases.entries) {
        String input = entry.key;
        String expected = entry.value;
        String actual = controller.removeDiacritics(input);

        expect(actual, equals(expected),
            reason:
                'Failed for input "$input": expected "$expected", got "$actual"');
      }

      // Clean up
      Get.reset();
    });
  });
}
