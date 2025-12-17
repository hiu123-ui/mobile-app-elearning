import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/danh_muc_model.dart';

class ApiService {
  static const String _baseUrl = 'https://elearningnew.cybersoft.edu.vn/api';
  static const String _tokenCybersoft =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0ZW5Mb3AiOiJCb290Y2FtcCA4NSIsIkhldEhhblN0cmluZyI6IjExLzAyLzIwMjYiLCJIZXRIYW5UaW1lIjoiMTc3MDc2ODAwMDAwMCIsIm5iZiI6MTc0MzAwODQwMCwiZXhwIjoxNzcwOTE1NjAwfQ.Myf9_YG00LMB7aQFoCISi0p2gKBdfDldz_hVR3VJ0IQ';

  // Headers chung
  static Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'TokenCybersoft': _tokenCybersoft,
      'Accept': 'application/json',
    };
  }

  // 1. Lấy danh sách danh mục
  static Future<List<DanhMucModel>> layDanhMucKhoaHoc({
    String? tenDanhMuc,
  }) async {
    try {
      // Tạo URL
      var url = Uri.parse('$_baseUrl/QuanLyKhoaHoc/LayDanhMucKhoaHoc');

      // Thêm query nếu có
      if (tenDanhMuc != null && tenDanhMuc.isNotEmpty) {
        url = Uri.parse('$url?tenDanhMuc=$tenDanhMuc');
      }

      // Gọi API
      final response = await http.get(url, headers: _headers);

      // Xử lý response
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Xử lý cả 2 trường hợp: có data hoặc response là list
        if (jsonResponse is Map && jsonResponse.containsKey('data')) {
          final data = jsonResponse['data'] as List;
          return data
              .map<DanhMucModel>((item) => DanhMucModel.fromJson(item))
              .toList();
        } else if (jsonResponse is List) {
          return jsonResponse
              .map<DanhMucModel>((item) => DanhMucModel.fromJson(item))
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Lỗi ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi API DanhMuc: $e');
      return [];
    }
  }

  // 2. Lấy danh sách khóa học
  static Future<List<dynamic>> layDanhSachKhoaHoc({
    String? tenKhoaHoc,
    String maNhom = 'GP01',
  }) async {
    try {
      // Tạo URL với query parameters
      var url = '$_baseUrl/QuanLyKhoaHoc/LayDanhSachKhoaHoc?MaNhom=$maNhom';
      if (tenKhoaHoc != null && tenKhoaHoc.isNotEmpty) {
        url += '&tenKhoaHoc=$tenKhoaHoc';
      }

      // Gọi API
      final response = await http.get(Uri.parse(url), headers: _headers);

      // Xử lý response
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Trả về data nếu có, hoặc response nếu là list
        if (jsonResponse is Map && jsonResponse.containsKey('data')) {
          return jsonResponse['data'] as List;
        } else if (jsonResponse is List) {
          return jsonResponse;
        } else {
          return [];
        }
      } else {
        throw Exception('Lỗi ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi API KhoaHoc: $e');
      return [];
    }
  }

  // lấy các khóa học theo danh mục

}
