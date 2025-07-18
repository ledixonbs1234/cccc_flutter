// Demo showing Vietnamese diacritic removal functionality
// This demonstrates how the search works with Vietnamese names

import '../lib/app/modules/home/controllers/home_controller.dart';
import '../lib/app/modules/home/models/cccdInfo.dart';

void main() {
  // Create a controller instance
  final controller = HomeController();

  // Add sample Vietnamese CCCD data
  controller.totalCCCD.addAll([
    CCCDInfo('Dương Lê Như Ngọc', '20/11/2021', '052321010762'),
    CCCDInfo('Nguyễn Văn Hùng', '15/05/1990', '052321010763'),
    CCCDInfo('Trần Thị Hạnh', '08/03/1985', '052321010764'),
    CCCDInfo('Lê Minh Đức', '22/12/1992', '052321010765'),
    CCCDInfo('Phạm Thị Hương', '10/07/1988', '052321010766'),
    CCCDInfo('Hoàng Văn Tuấn', '03/09/1995', '052321010767'),
  ]);

  print('=== Vietnamese Search Demo ===\n');

  // Test cases showing how search works without diacritics
  final testCases = [
    {'search': 'Ngoc', 'should_find': 'Ngọc'},
    {'search': 'Duong', 'should_find': 'Dương'},
    {'search': 'Hung', 'should_find': 'Hùng'},
    {'search': 'Hanh', 'should_find': 'Hạnh'},
    {'search': 'Duc', 'should_find': 'Đức'},
    {'search': 'Huong', 'should_find': 'Hương'},
    {'search': 'Tuan', 'should_find': 'Tuấn'},
  ];

  for (var testCase in testCases) {
    String searchTerm = testCase['search']!;
    String expectedFind = testCase['should_find']!;

    // Find matching CCCD using the same logic as searchCCCD method
    String normalizedSearchValue =
        controller.removeDiacritics(searchTerm.toLowerCase());

    int foundIndex = controller.totalCCCD.indexWhere((item) {
      String normalizedName =
          controller.removeDiacritics(item.Name.toLowerCase());
      return normalizedName.contains(normalizedSearchValue);
    });

    if (foundIndex != -1) {
      CCCDInfo foundCCCD = controller.totalCCCD[foundIndex];
      print(
          '✅ Search "$searchTerm" → Found: "${foundCCCD.Name}" (contains "$expectedFind")');

      // Calculate scroll position
      double estimatedItemHeight = 88.0;
      double scrollPosition = foundIndex * estimatedItemHeight;
      print(
          '   📍 Would scroll to position: ${scrollPosition}px (item $foundIndex)\n');
    } else {
      print('❌ Search "$searchTerm" → No match found\n');
    }
  }

  print('=== Diacritic Removal Examples ===\n');

  // Show some examples of diacritic removal
  final examples = [
    'Ngọc → ${controller.removeDiacritics('Ngọc')}',
    'Dương → ${controller.removeDiacritics('Dương')}',
    'Hùng → ${controller.removeDiacritics('Hùng')}',
    'Hạnh → ${controller.removeDiacritics('Hạnh')}',
    'Đức → ${controller.removeDiacritics('Đức')}',
    'Hương → ${controller.removeDiacritics('Hương')}',
    'Tuấn → ${controller.removeDiacritics('Tuấn')}',
  ];

  for (var example in examples) {
    print('🔄 $example');
  }

  print('\n=== Search Features ===');
  print('✨ Case-insensitive search');
  print('✨ Vietnamese diacritic removal (optimized regex-based)');
  print('✨ Accurate scroll positioning');
  print('✨ Works with AlwaysScrollableScrollPhysics');
  print('✨ Handles empty search gracefully');
  print('✨ Prevents scrolling beyond max extent');
  print('✨ Efficient regex patterns for better performance');
}
