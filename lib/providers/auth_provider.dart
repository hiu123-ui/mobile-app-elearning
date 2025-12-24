// [file name]: providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  // Constructor: load user từ local storage khi khởi động
  AuthProvider() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await AuthService.getUserData();
      if (user != null) {
        _user = user;
      }
    } catch (e) {
      print('Lỗi khi load user từ storage: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Đăng nhập
  Future<bool> login(String taiKhoan, String matKhau) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await ApiService.dangNhap(
        taiKhoan: taiKhoan,
        matKhau: matKhau,
      );
      
      if (user != null) {
        _user = user;
        notifyListeners();

        try {
          final info = await ApiService.layThongTinNguoiDung();
          if (info is Map<String, dynamic>) {
            final refreshedUser = UserModel.fromJson(info);
            _user = refreshedUser;
            await AuthService.saveUserData(refreshedUser);
            notifyListeners();
          }
        } catch (e) {
          // giữ nguyên user từ login nếu API thông tin người dùng lỗi
        }
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    await AuthService.clearAuthData();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Làm mới user data từ API
  Future<void> refreshUserData() async {
    try {
      final userData = await AuthService.getUserData();
      if (userData != null) {
        _user = userData;
        notifyListeners();
      }
    } catch (e) {
      print('Lỗi khi refresh user data: $e');
    }
  }

  Future<bool> updateProfile({required String hoTen, required String email, required String soDT, String? matKhau}) async {
    if (_user == null) return false;
    try {
      final ok = await ApiService.capNhatThongTinNguoiDung(
        taiKhoan: _user!.taiKhoan,
        hoTen: hoTen,
        email: email,
        soDT: soDT,
        maNhom: _user!.maNhom,
        maLoaiNguoiDung: _user!.maLoaiNguoiDung,
        matKhau: matKhau,
      );
      if (ok) {
        try {
          final info = await ApiService.layThongTinNguoiDung();
          if (info is Map<String, dynamic>) {
            final refreshedUser = UserModel.fromJson({
              ...info,
              'accessToken': _user!.accessToken,
            });
            _user = refreshedUser;
            await AuthService.saveUserData(refreshedUser);
            notifyListeners();
          }
        } catch (_) {}
      }
      return ok;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
