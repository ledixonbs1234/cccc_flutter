import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class VNPostService {
  static const String baseUrl = 'https://hanhchinhcong.vnpost.vn';
  static const String loginUrl = '$baseUrl/login';
  static const String searchUrl = '$baseUrl/giaodich/timkiem';

  // Cookie storage
  final _storage = GetStorage();
  final String _cookieKey = 'vnpost_cookies';

  // Singleton pattern
  static final VNPostService _instance = VNPostService._internal();
  factory VNPostService() => _instance;
  VNPostService._internal();

  // HTTP client with cookie handling
  final http.Client _client = http.Client();

  // Get stored cookies
  String? _getCookies() {
    return _storage.read(_cookieKey);
  }

  // Save cookies from response
  void _saveCookies(http.Response response) {
    final setCookieHeader = response.headers['set-cookie'];
    if (setCookieHeader != null) {
      // Parse multiple cookies if present
      final cookies = setCookieHeader.split(',').map((cookie) {
        // Extract just the cookie value before first semicolon
        return cookie.split(';')[0].trim();
      }).join('; ');
      
      _storage.write(_cookieKey, cookies);
      print('Saved cookies: $cookies');
    }
  }

  // Clear stored cookies
  void clearCookies() {
    _storage.remove(_cookieKey);
  }

  // Add cookies to request headers
  Map<String, String> _getHeaders({bool includeFormData = false, String? referer}) {
    final headers = {
      'accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
      'accept-language': 'vi,en-US;q=0.9,en;q=0.8',
      'cache-control': 'no-cache',
      'pragma': 'no-cache',
      'sec-ch-ua':
          '"Microsoft Edge";v="141", "Not?A_Brand";v="8", "Chromium";v="141"',
      'sec-ch-ua-mobile': '?0',
      'sec-ch-ua-platform': '"Windows"',
      'sec-fetch-dest': 'document',
      'sec-fetch-mode': 'navigate',
      'sec-fetch-site': 'same-origin',
      'sec-fetch-user': '?1',
      'upgrade-insecure-requests': '1',
    };

    if (includeFormData) {
      headers['content-type'] = 'application/x-www-form-urlencoded';
    }

    if (referer != null) {
      headers['referer'] = referer;
    }

    final cookies = _getCookies();
    if (cookies != null) {
      headers['cookie'] = cookies;
      print('Using cookies: $cookies');
    }

    return headers;
  }

  // Get CSRF token from login page
  Future<String?> _getCsrfToken() async {
    try {
      final response = await _client.get(
        Uri.parse(loginUrl),
        headers: _getHeaders(),
      );

      _saveCookies(response);

      if (response.statusCode == 200) {
        // Parse HTML to extract CSRF token
        final html = response.body;
        final tokenMatch =
            RegExp(r'name="_token"\s+value="([^"]+)"').firstMatch(html);
        if (tokenMatch != null) {
          return tokenMatch.group(1);
        }
      }
      return null;
    } catch (e) {
      print('Error getting CSRF token: $e');
      return null;
    }
  }

  // Login to VNPost
  Future<bool> login({required String username, required String password}) async {
    try {
      // Get CSRF token first
      final token = await _getCsrfToken();
      if (token == null) {
        print('Failed to get CSRF token');
        return false;
      }

      // Prepare login data
      final body =
          '_token=$token&username=${Uri.encodeComponent(username)}&password=${Uri.encodeComponent(password)}';

      // Perform login
      final response = await _client.post(
        Uri.parse(loginUrl),
        headers: _getHeaders(includeFormData: true, referer: loginUrl),
        body: body,
      );

      _saveCookies(response);
      
      print('Login response status: ${response.statusCode}');

      // Check if login successful (302 redirect or 200)
      if (response.statusCode == 302 || response.statusCode == 200) {
        // Follow redirect if needed
        if (response.statusCode == 302) {
          final location = response.headers['location'];
          if (location != null) {
            final redirectUrl =
                location.startsWith('http') ? location : '$baseUrl$location';

            final redirectResponse = await _client.get(
              Uri.parse(redirectUrl),
              headers: _getHeaders(referer: loginUrl),
            );
            _saveCookies(redirectResponse);
            print('Followed redirect to: $redirectUrl');
          }
        }
        
        // Verify login by checking if we can access a protected page
        final verifyResponse = await _client.get(
          Uri.parse(searchUrl),
          headers: _getHeaders(referer: loginUrl),
        );
        _saveCookies(verifyResponse);
        
        // Check if response is not login page
        final isLoginPage = verifyResponse.body.contains('Đăng Nhập') || 
                           verifyResponse.body.contains('Tên tài khoản');
        
        if (!isLoginPage) {
          print('Login verified successfully');
          return true;
        } else {
          print('Login verification failed - still on login page');
          return false;
        }
      }

      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Search CCCD on VNPost
  Future<VNPostSearchResult> search({
    String? hoTen,
    String? ngaySinh,
    String? maBuuGui,
    String? ngayBatDau,
    String? ngayKetThuc,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{
        'NhomThuTuc': '',
        'MaThuTuc': '',
        'HoTen': hoTen ?? '',
        'NgaySinh': ngaySinh ?? '',
        'MaHoSo': '',
        'MaBuuGui': maBuuGui ?? '',
        'MaCaNhan': '',
        'TrangThai': '',
        'NgayBatDau': ngayBatDau ?? _formatDate(DateTime.now()),
        'NgayKetThuc': ngayKetThuc ?? _formatDate(DateTime.now()),
      };

      final uri = Uri.parse(searchUrl).replace(queryParameters: queryParams);

      print('Searching with URL: $uri');

      final response = await _client.get(
        uri,
        headers: _getHeaders(referer: searchUrl),
      );

      _saveCookies(response);

      print('Search response status: ${response.statusCode}');

      // Check if response is login page (even with 200 status)
      final isLoginPage = response.body.contains('Đăng Nhập') || 
                         response.body.contains('Tên tài khoản') ||
                         response.body.contains('PHẦN MỀM HỖ TRỢ ĐĂNG KÝ');

      if (isLoginPage) {
        print('Detected login page - needs authentication');
        return VNPostSearchResult(
          success: false,
          needsLogin: true,
          htmlResponse: response.body,
          statusCode: response.statusCode,
        );
      }

      // Check response status
      if (response.statusCode == 200) {
        // Success - parse response
        print('Search successful');
        return VNPostSearchResult(
          success: true,
          needsLogin: false,
          htmlResponse: response.body,
          statusCode: response.statusCode,
        );
      } else if (response.statusCode == 302) {
        // Redirect to login - need authentication
        print('Got 302 redirect - needs authentication');
        return VNPostSearchResult(
          success: false,
          needsLogin: true,
          htmlResponse: '',
          statusCode: response.statusCode,
        );
      } else {
        // Other error
        print('Search error with status: ${response.statusCode}');
        return VNPostSearchResult(
          success: false,
          needsLogin: false,
          htmlResponse: response.body,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('Search error: $e');
      return VNPostSearchResult(
        success: false,
        needsLogin: false,
        htmlResponse: 'Error: $e',
        statusCode: 0,
      );
    }
  }

  // Format date as dd/MM/yyyy
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  // Dispose client
  void dispose() {
    _client.close();
  }
}

// Result model for search
class VNPostSearchResult {
  final bool success;
  final bool needsLogin;
  final String htmlResponse;
  final int statusCode;

  VNPostSearchResult({
    required this.success,
    required this.needsLogin,
    required this.htmlResponse,
    required this.statusCode,
  });
}
