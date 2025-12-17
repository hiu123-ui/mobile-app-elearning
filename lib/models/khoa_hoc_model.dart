class KhoaHocModel {
  final String maKhoaHoc;
  final String tenKhoaHoc;
  final String moTa;
  final String hinhAnh;
  final String luotXem;
  final dynamic nguoiTao;
  final String maNhom;
  final String soLuongHocVien;
  final String ngayTao;
  final String danhGia; // Thêm trường đánh giá
  final String thoiLuong; // Thêm trường thời lượng

  KhoaHocModel({
    required this.maKhoaHoc,
    required this.tenKhoaHoc,
    required this.moTa,
    required this.hinhAnh,
    required this.luotXem,
    required this.nguoiTao,
    required this.maNhom,
    required this.soLuongHocVien,
    required this.ngayTao,
    this.danhGia = '0',
    this.thoiLuong = '0',
  });

  factory KhoaHocModel.fromJson(Map<String, dynamic> json) {
    return KhoaHocModel(
      maKhoaHoc: json['maKhoaHoc']?.toString() ?? '',
      tenKhoaHoc: json['tenKhoaHoc']?.toString() ?? 'Không có tên',
      moTa: json['moTa']?.toString() ?? 'Không có mô tả',
      hinhAnh: json['hinhAnh']?.toString() ?? '',
      luotXem: json['luotXem']?.toString() ?? '0',
      nguoiTao: json['nguoiTao'] ?? {},
      maNhom: json['maNhom']?.toString() ?? 'GP01',
      soLuongHocVien: json['soLuongHocVien']?.toString() ?? '0',
      ngayTao: json['ngayTao']?.toString() ?? '',
      danhGia: json['danhGia']?.toString() ?? '0',
      thoiLuong: json['thoiLuong']?.toString() ?? '0 giờ',
    );
  }

  String getTenNguoiTao() {
    if (nguoiTao is Map) {
      return (nguoiTao as Map)['hoTen']?.toString() ?? 'Ẩn danh';
    } else if (nguoiTao is String) {
      return nguoiTao as String;
    }
    return 'Ẩn danh';
  }
}