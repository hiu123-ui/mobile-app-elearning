import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/danh_muc_model.dart';
import '../models/khoa_hoc_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

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

  // 1. Lấy danh sách danh mục khóa học 
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

  // 2. Lấy danh sách khóa học 
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

  static Future<KhoaHocModel?> layThongTinKhoaHoc({
    required String maKhoaHoc,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/QuanLyKhoaHoc/LayThongTinKhoaHoc?maKhoaHoc=$maKhoaHoc');
      final response = await http.get(url, headers: _headers);
      print('URL LayThongTinKhoaHoc: $url');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        Map<String, dynamic>? data;
        if (jsonResponse is Map && jsonResponse.containsKey('data')) {
          final v = jsonResponse['data'];
          if (v is Map) data = Map<String, dynamic>.from(v);
        } else if (jsonResponse is Map && jsonResponse.containsKey('content')) {
          final v = jsonResponse['content'];
          if (v is Map) data = Map<String, dynamic>.from(v);
        } else if (jsonResponse is Map) {
          data = Map<String, dynamic>.from(jsonResponse);
        }
        if (data != null) {
          return KhoaHocModel.fromJson(data);
        }
        return null;
      } else {
        print('Lỗi ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Lỗi API layThongTinKhoaHoc: $e');
      return null;
    }
  }

  // Đăng ký khóa học cho tài khoản hiện tại
  static Future<bool> dangKyKhoaHoc({
    required String maKhoaHoc,
    required String taiKhoan,
  }) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Chưa đăng nhập');
      }

      final url = Uri.parse('$_baseUrl/QuanLyKhoaHoc/DangKyKhoaHoc');
      final body = jsonEncode({
        'maKhoaHoc': maKhoaHoc,
        'taiKhoan': taiKhoan,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'TokenCybersoft': _tokenCybersoft,
        },
        body: body,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final msg = response.body.isNotEmpty ? response.body : 'Đăng ký thất bại';
        throw Exception('Lỗi ${response.statusCode}: $msg');
      }
    } catch (e) {
      print('Lỗi API dangKyKhoaHoc: $e');
      rethrow;
    }
  }

  // Hủy ghi danh khóa học cho tài khoản hiện tại
  static Future<bool> huyDangKyKhoaHoc({
    required String maKhoaHoc,
    required String taiKhoan,
  }) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Chưa đăng nhập');
      }

      final url = Uri.parse('$_baseUrl/QuanLyKhoaHoc/HuyGhiDanh');
      final body = jsonEncode({
        'maKhoaHoc': maKhoaHoc,
        'taiKhoan': taiKhoan,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'TokenCybersoft': _tokenCybersoft,
        },
        body: body,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final msg = response.body.isNotEmpty ? response.body : 'Hủy ghi danh thất bại';
        throw Exception('Lỗi ${response.statusCode}: $msg');
      }
    } catch (e) {
      print('Lỗi API huyDangKyKhoaHoc: $e');
      rethrow;
    }
  }

  // Lấy thông tin tài khoản (bao gồm danh sách khóa học đã ghi danh)
  static Future<List<KhoaHocModel>> layKhoaHocGhiDanhCuaTaiKhoan() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Chưa đăng nhập');
      }

      final url = Uri.parse('$_baseUrl/QuanLyNguoiDung/ThongTinTaiKhoan');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'TokenCybersoft': _tokenCybersoft,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = (data is Map && data['chiTietKhoaHocGhiDanh'] is List)
            ? data['chiTietKhoaHocGhiDanh'] as List
            : [];
        return list.map<KhoaHocModel>((item) {
          final m = Map<String, dynamic>.from(item as Map);
          return KhoaHocModel(
            maKhoaHoc: m['maKhoaHoc']?.toString() ?? '',
            tenKhoaHoc: m['tenKhoaHoc']?.toString() ?? 'Không có tên',
            moTa: m['moTa']?.toString() ?? '',
            hinhAnh: m['hinhAnh']?.toString() ?? '',
            luotXem: '0',
            nguoiTao: m['tenNguoiTao']?.toString() ?? 'Ẩn danh',
            maNhom: m['maNhom']?.toString() ?? 'GP01',
            soLuongHocVien: '0',
            ngayTao: m['ngayTao']?.toString() ?? '',
            danhGia: '0',
            thoiLuong: '0',
          );
        }).toList();
      } else {
        throw Exception('Lỗi ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Lỗi API layKhoaHocGhiDanhCuaTaiKhoan: $e');
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

        if (jsonResponse is Map<String, dynamic>) {
          if (jsonResponse.containsKey('accessToken')) {
            final user = UserModel.fromJson(jsonResponse);
            
            // Lưu access token và user data
            await AuthService.saveAccessToken(jsonResponse['accessToken']);
            await AuthService.saveUserData(user);
            
            return user;
          } else {
            print('Response không chứa accessToken: $jsonResponse');
            throw Exception('Đăng nhập thất bại: Không có accessToken');
          }
        } else {
          throw Exception('Dữ liệu trả về không đúng định dạng');
        }
      } else {
        String errorMsg = 'Đăng nhập thất bại (mã ${response.statusCode})';
        try {
          final errorJson = jsonDecode(response.body);
          if (errorJson is Map && errorJson.containsKey('message')) {
            errorMsg += ': ${errorJson['message']}';
          }
        } catch (_) {}
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('Lỗi API dangNhap: $e');
      rethrow;
    }
  }

  // Thêm phương thức lấy headers có authorization
  static Future<Map<String, String>> getHeadersWithAuth() async {
    final token = await AuthService.getAccessToken();
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'TokenCybersoft': _tokenCybersoft,
      'Accept': 'application/json',
    };
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // Ví dụ API cần authorization
  static Future<Map<String, dynamic>> layThongTinNguoiDung() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      final url = Uri.parse('$_baseUrl/QuanLyNguoiDung/ThongTinNguoiDung');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'TokenCybersoft': _tokenCybersoft,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Lỗi ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Lỗi API layThongTinNguoiDung: $e');
      rethrow;
    }
  }

  // Cập nhật thông tin người dùng
  static Future<bool> capNhatThongTinNguoiDung({
    required String taiKhoan,
    required String hoTen,
    required String email,
    required String soDT,
    String? maNhom,
    String? maLoaiNguoiDung,
    String? matKhau,
  }) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Chưa đăng nhập');
      }

      final url = Uri.parse('$_baseUrl/QuanLyNguoiDung/CapNhatThongTinNguoiDung');
      final Map<String, dynamic> payload = {
        'taiKhoan': taiKhoan,
        'hoTen': hoTen,
        'email': email,
        'soDT': soDT,
        'maNhom': maNhom ?? 'GP01',
        'maLoaiNguoiDung': maLoaiNguoiDung ?? 'HV',
      };
      if (matKhau != null && matKhau.trim().isNotEmpty) {
        payload['matKhau'] = matKhau.trim();
      }
      final body = jsonEncode(payload);

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'TokenCybersoft': _tokenCybersoft,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Lỗi ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Lỗi API capNhatThongTinNguoiDung: $e');
      rethrow;
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

      print(' Đăng ký URL: $url');
      print(' Thông tin đăng ký: $registerRequest');

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(registerRequest),
      );

      print(' Response Status Code: ${response.statusCode}');
      print(' Response Body: ${response.body}');

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
      print(' Lỗi API dangKy: $e');
      rethrow;
    }
  }
}