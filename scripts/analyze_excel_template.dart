import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';

void main() async {
  try {
    // Read the cc.xlsx template file
    final file = File('assets/cc.xlsx');
    if (!await file.exists()) {
      print('Error: cc.xlsx file not found in assets folder');
      return;
    }

    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    print('=== CC.XLSX TEMPLATE ANALYSIS ===\n');
    
    // Analyze each sheet
    for (String sheetName in excel.tables.keys) {
      final sheet = excel.tables[sheetName]!;
      print('Sheet: $sheetName');
      print('Max Columns: ${sheet.maxColumns}');
      print('Max Rows: ${sheet.maxRows}');
      print('');

      // Print headers (first row)
      print('Headers (Row 1):');
      for (int col = 0; col < sheet.maxColumns; col++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
        final value = cell.value?.toString() ?? '';
        print('  Column $col: "$value"');
      }
      print('');

      // Print first few data rows if they exist
      if (sheet.maxRows > 1) {
        print('Sample Data Rows:');
        for (int row = 1; row < (sheet.maxRows > 5 ? 5 : sheet.maxRows); row++) {
          print('  Row ${row + 1}:');
          for (int col = 0; col < sheet.maxColumns; col++) {
            final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
            final value = cell.value?.toString() ?? '';
            print('    Column $col: "$value"');
          }
        }
      }
      print('');

      // Check for any formatting or styles
      print('Cell Formatting Analysis:');
      for (int col = 0; col < (sheet.maxColumns > 10 ? 10 : sheet.maxColumns); col++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
        if (cell.cellStyle != null) {
          print('  Column $col has custom styling');
        }
      }
      print('');
    }

    // Suggest column mapping based on common CCCD fields
    print('=== SUGGESTED COLUMN MAPPING ===');
    print('Based on CCCD data structure, suggested mapping:');
    print('Column 0: STT (Sequential Number)');
    print('Column 1: CCCD ID (Id)');
    print('Column 2: Họ tên (Name)');
    print('Column 3: Ngày sinh (NgaySinh)');
    print('Column 4: Giới tính (gioiTinh)');
    print('Column 5: Địa chỉ (DiaChi)');
    print('Column 6: Mã bưu gửi (maBuuGui)');
    print('Column 7: Ngày làm CCCD (NgayLamCCCD) - if available');
    print('');

  } catch (e) {
    print('Error analyzing Excel template: $e');
  }
}
