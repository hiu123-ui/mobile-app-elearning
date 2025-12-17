// [file name]: services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/danh_muc_model.dart';
import '../models/user_model.dart';

class ApiService {
  static const String _baseUrl = 'https://elearningnew.cybersoft.edu.vn/api';
  static const String _tokenCybersoft =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0ZW5Mb3AiOiJCb290Y2FtcCA4NSIsIkhldEhhblN0cmluZyI6IjExLzAyLzIwMjYiLCJIZXRIYW5UaW1lIjoiMTc3MDc2ODAwMDAwMCIsIm5iZiI6MTc0MzAwODQwMCwiZXhwIjoxNzcwOTE1NjAwfQ.Myf9_YG00LMB7aQFoCISi0p2gKBdfDldz_hVR3J0IQ';

  static Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'TokenCybersoft': _tokenCybersoft,
      'Accept': 'application/json',
    };
  }

  // 1. Lấy danh sách danh mục khóa học (giữ nguyên, đã ổn định)
  static Future<List<DanhMucModel>> layDanhMucKhoaHoc({
    String? tenDanhMuc,
  }) async {
    try {
      var url = Uri.parse('$_baseUrl/QuanLyKhoaHoc/LayDanhMucKhoaHoc');
      if (tenDanhMuc != null && tenDanhMuc.isNotEmpty) {
        url = Uri.parse(
          '$_baseUrl/QuanLyKhoaHoc/LayDanhMucKhoaHoc?tenDanhMuc=$tenDanhMuc',
        );
      }

      final response = await http.get(url, headers: _headers);
      print('URL Danh mục: $url');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        List data = [];
        if (jsonResponse is Map && jsonResponse.containsKey('data')) {
          data = jsonResponse['data'];
        } else if (jsonResponse is Map && jsonResponse.containsKey('content')) {
          data = jsonResponse['content'];
        } else if (jsonResponse is List) {
          data = jsonResponse;
        }

        return data
            .map<DanhMucModel>((item) => DanhMucModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Lỗi ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Lỗi API layDanhMucKhoaHoc: $e');
      return [];
    }
  }

  // 2. Lấy danh sách khóa học (giữ nguyên)
  static Future<List<dynamic>> layDanhSachKhoaHoc({
    String? tenKhoaHoc,
    String maNhom = 'GP01',
  }) async {
    try {
      String urlStr =
          '$_baseUrl/QuanLyKhoaHoc/LayDanhSachKhoaHoc?MaNhom=$maNhom';
      if (tenKhoaHoc != null && tenKhoaHoc.isNotEmpty) {
        urlStr += '&tenKhoaHoc=$tenKhoaHoc';
      }

      final response = await http.get(Uri.parse(urlStr), headers: _headers);
      print('URL Danh sách KH: $urlStr');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        List data = [];
        if (jsonResponse is Map && jsonResponse.containsKey('data')) {
          data = jsonResponse['data'];
        } else if (jsonResponse is Map && jsonResponse.containsKey('content')) {
          data = jsonResponse['content'];
        } else if (jsonResponse is List) {
          data = jsonResponse;
        }
        return data;
      } else {
        throw Exception('Lỗi ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Lỗi API layDanhSachKhoaHoc: $e');
      return [];
    }
  }

  // 3. Lấy khóa học theo danh mục (giữ nguyên chuẩn hóa maDanhMuc)
  static Future<List<dynamic>> layKhoaHocTheoDanhMuc({
    required String maDanhMuc,
    String maNhom = 'GP01',
  }) async {
    try {
      // Chuẩn hóa mã danh mục
      String normalizedMaDanhMuc = maDanhMuc
          .toLowerCase()
          .replaceAll('đ', 'd')
          .split(' ')
          .map((word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '')
          .join('');

      final urlStr =
          '$_baseUrl/QuanLyKhoaHoc/LayKhoaHocTheoDanhMuc?maDanhMuc=$normalizedMaDanhMuc&MaNhom=$maNhom';
      final url = Uri.parse(urlStr);

      print('API Call URL: $url');

      final response = await http.get(url, headers: _headers);

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        List data = [];
        if (jsonResponse is Map && jsonResponse.containsKey('data')) {
          data = jsonResponse['data'] as List;
        } else if (jsonResponse is Map && jsonResponse.containsKey('content')) {
          data = jsonResponse['content'] as List;
        } else if (jsonResponse is List) {
          data = jsonResponse;
        }

        print('Số khóa học tìm được: ${data.length}');
        return data;
      } else {
        print('Lỗi HTTP: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Lỗi API layKhoaHocTheoDanhMuc: $e');
      return [];
    }
  }

  // Phương thức đăng nhập - SỬA LẠI ĐỂ HOẠT ĐỘNG ỔN ĐỊNH
  static Future<UserModel?> dangNhap({
    required String taiKhoan,
    required String matKhau,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/QuanLyNguoiDung/DangNhap');

      final loginRequest = {
        'taiKhoan': taiKhoan,
        'matKhau': matKhau,
      };

      print('Đăng nhập URL: $url');
      print('Body request: ${jsonEncode(loginRequest)}');

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(loginRequest),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Cybersoft thường trả về user object trực tiếp (không bọc trong data/content)
        if (jsonResponse is Map<String, dynamic>) {
          // Kiểm tra nếu có accessToken hoặc các field user
          if (jsonResponse.containsKey('accessToken') || jsonResponse.containsKey('taiKhoan')) {
            return UserModel.fromJson(jsonResponse);
          } else {
            print('Response không chứa dữ liệu user hợp lệ: $jsonResponse');
            throw Exception('Đăng nhập thất bại: Dữ liệu không hợp lệ');
          }
        } else {
          throw Exception('Dữ liệu trả về không đúng định dạng');
        }
      } else {
        // Xử lý lỗi chi tiết hơn
        String errorMsg = 'Đăng nhập thất bại (mã ${response.statusCode})';
        try {
          final errorJson = jsonDecode(response.body);
          if (errorJson is Map && errorJson.containsKey('message')) {
            errorMsg += ': ${errorJson['message']}';
          } else if (errorJson is String) {
            errorMsg += ': $errorJson';
          }
        } catch (_) {}
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('Lỗi API dangNhap: $e');
      rethrow; // Rethrow để UI xử lý (hiển thị thông báo)
    }
  }

   static Future<Map<String, dynamic>> dangKy({
    required String taiKhoan,
    required String matKhau,
    required String hoTen,
    required String soDT,
    required String email,
    required String maNhom,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/QuanLyNguoiDung/DangKy');
      
      final registerRequest = {
        'taiKhoan': taiKhoan,
        'matKhau': matKhau,
        'hoTen': hoTen,
        'soDT': soDT,
        'email': email,
        'maNhom': maNhom,
      };

      print('📝 Đăng ký URL: $url');
      print('📝 Thông tin đăng ký: $registerRequest');

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(registerRequest),
      );

      print('📝 Response Status Code: ${response.statusCode}');
      print('📝 Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // Đăng ký thành công
        if (jsonResponse is Map && jsonResponse.containsKey('message')) {
          return {
            'success': true,
            'message': jsonResponse['message'],
            'data': jsonResponse
          };
        } else {
          return {
            'success': true,
            'message': 'Đăng ký thành công!',
            'data': jsonResponse
          };
        }
      } else {
        // Đăng ký thất bại
        String errorMessage = 'Đăng ký thất bại';
        
        if (jsonResponse is Map) {
          if (jsonResponse.containsKey('message')) {
            errorMessage = jsonResponse['message'];
          } else if (jsonResponse.containsKey('errors')) {
            final errors = jsonResponse['errors'];
            if (errors is List && errors.isNotEmpty) {
              errorMessage = errors.first.toString();
            }
          }
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ Lỗi API dangKy: $e');
      rethrow;
    }
  }
}