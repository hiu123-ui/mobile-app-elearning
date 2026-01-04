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

  LoginRequest({required this.taiKhoan, required this.matKhau});

  Map<String, dynamic> toJson() {
    return {'taiKhoan': taiKhoan, 'matKhau': matKhau};
  }
}

// đăng ki
class RegisterRequest {
  final String taiKhoan; 
  final String matKhau; 
  final String hoTen;
  final String soDT; 
  final String email; 
  final String maNhom; 

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
