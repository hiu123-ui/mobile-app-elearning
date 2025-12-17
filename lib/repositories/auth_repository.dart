// [file name]: repositories/auth_repository.dart
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthRepository {
  // Đăng nhập - ĐÃ SỬA ĐỂ TƯƠNG THÍCH VỚI ApiService MỚI (trả về UserModel? nullable)
  Future<UserModel> dangNhap({
    required String taiKhoan,
    required String matKhau,
  }) async {
    try {
      final user = await ApiService.dangNhap(
        taiKhoan: taiKhoan,
        matKhau: matKhau,
      );

      // Nếu ApiService trả về null → nghĩa là đăng nhập thất bại
      if (user == null) {
        throw Exception('Tài khoản hoặc mật khẩu không đúng');
      }

      return user;
    } catch (e) {
      print('Repository Error (dangNhap): $e');
      // Chuyển lỗi thành thông báo thân thiện hơn cho UI
      if (e is Exception) {
        rethrow; // Giữ nguyên exception để UI bắt và hiển thị
      } else {
        throw Exception('Đăng nhập thất bại. Vui lòng thử lại!');
      }
    }
  }

  // Đăng ký
   // Đăng ký - trả về Map thay vì String
  Future<Map<String, dynamic>> dangKy({
    required String taiKhoan,
    required String matKhau,
    required String hoTen,
    required String soDT,
    required String email,
    required String maNhom,
  }) async {
    try {
      final result = await ApiService.dangKy(
        taiKhoan: taiKhoan,
        matKhau: matKhau,
        hoTen: hoTen,
        soDT: soDT,
        email: email,
        maNhom: maNhom,
      );
      return result;
    } catch (e) {
      print('❌ Repository Error (dangKy): $e');
      rethrow;
    }
  }
}