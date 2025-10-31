import 'package:html/parser.dart' as html_parser;
import '../modules/tim_kiem/models/vnpost_transaction.dart';

class VNPostHtmlParser {
  // Parse HTML response to extract transaction list
  static List<VNPostTransaction> parseTransactions(String htmlContent) {
    final document = html_parser.parse(htmlContent);
    final transactions = <VNPostTransaction>[];

    try {
      // Find the table body with id="listTbody"
      final tbody = document.getElementById('listTbody');

      if (tbody == null) {
        print('Table body not found in HTML');
        return transactions;
      }

      // Get all rows in tbody
      final rows = tbody.querySelectorAll('tr');

      for (var row in rows) {
        try {
          final cells = row.querySelectorAll('td');

          if (cells.length < 8) {
            continue; // Skip incomplete rows
          }

          // Extract data from cells
          final stt = _cleanText(cells[0].text);
          final trangThai = _cleanText(cells[2].text);
          final hoTen = _cleanText(cells[3].text);
          final maBuuGui = _cleanText(cells[4].text);
          final cuocChuyenPhat = _cleanText(cells[5].text);

          // Get procedure info (index 12)
          final maThuTuc = cells.length > 12 ? _cleanText(cells[12].text) : '';

          // Get creation date (index 15)
          final ngayTao = cells.length > 15 ? _cleanText(cells[15].text) : '';

          final transaction = VNPostTransaction(
            stt: stt,
            trangThai: trangThai,
            hoTen: hoTen,
            maBuuGui: maBuuGui,
            cuocChuyenPhat: cuocChuyenPhat,
            maThuTuc: maThuTuc,
            ngayTao: ngayTao,
          );

          transactions.add(transaction);
        } catch (e) {
          print('Error parsing row: $e');
          continue;
        }
      }

      // Also try to get total count from alert
      final alertInfo = document.querySelector('.alert.alert-info strong');
      if (alertInfo != null) {
        final totalText = _cleanText(alertInfo.text);
        print('Total transactions found: $totalText');
      }
    } catch (e) {
      print('Error parsing HTML: $e');
    }

    return transactions;
  }

  // Clean text by removing extra whitespace and newlines
  static String _cleanText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // Check if HTML indicates no results
  static bool hasNoResults(String htmlContent) {
    final document = html_parser.parse(htmlContent);
    final tbody = document.getElementById('listTbody');

    if (tbody == null) return true;

    final rows = tbody.querySelectorAll('tr');
    return rows.isEmpty;
  }

  // Get total count from HTML
  static int getTotalCount(String htmlContent) {
    final document = html_parser.parse(htmlContent);
    final alertInfo = document.querySelector('.alert.alert-info strong');

    if (alertInfo != null) {
      final totalText = _cleanText(alertInfo.text);
      return int.tryParse(totalText) ?? 0;
    }

    return 0;
  }
}
