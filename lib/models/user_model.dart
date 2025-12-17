// [file name]: models/user_model.dart
class UserModel {
  final String taiKhoan;
  final String hoTen;
  final String email;
  final String soDT;
  final String maNhom;
  final String maLoaiNguoiDung;
  final String accessToken;

  UserModel({
    required this.taiKhoan,
    required this.hoTen,
    required this.email,
    required this.soDT,
    required this.maNhom,
    required this.maLoaiNguoiDung,
    required this.accessToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      taiKhoan: json['taiKhoan']?.toString() ?? '',
      hoTen: json['hoTen']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      soDT: json['soDT']?.toString() ?? '',
      maNhom: json['maNhom']?.toString() ?? 'GP01',
      maLoaiNguoiDung: json['maLoaiNguoiDung']?.toString() ?? '',
      accessToken: json['accessToken']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taiKhoan': taiKhoan,
      'hoTen': hoTen,
      'email': email,
      'soDT': soDT,
      'maNhom': maNhom,
      'maLoaiNguoiDung': maLoaiNguoiDung,
      'accessToken': accessToken,
    };
  }
}

class LoginRequest {
  final String taiKhoan;
  final String matKhau;

  LoginRequest({
    required this.taiKhoan,
    required this.matKhau,
  });

  Map<String, dynamic> toJson() {
    return {
      'taiKhoan': taiKhoan,
      'matKhau': matKhau,
    };
  }


  
}
// [file name]: models/user_model.dart
class RegisterRequest {
  final String taiKhoan;    // "askRoom" trong hình ảnh
  final String matKhau;     // "maskRoom" trong hình ảnh
  final String hoTen;       // "hofen" trong hình ảnh
  final String soDT;        // "support" trong hình ảnh
  final String email;       // "email"
  final String maNhom;      // "sashroom" trong hình ảnh

  RegisterRequest({
    required this.taiKhoan,
    required this.matKhau,
    required this.hoTen,
    required this.soDT,
    required this.email,
    required this.maNhom,
  });

  Map<String, dynamic> toJson() {
    return {
      'taiKhoan': taiKhoan,
      'matKhau': matKhau,
      'hoTen': hoTen,
      'soDT': soDT,
      'email': email,
      'maNhom': maNhom,
    };
  }
}