class DanhMucModel {
  final String maDanhMuc;
  final String tenDanhMuc;
  final String hinhAnh;

  DanhMucModel({
    required this.maDanhMuc,
    required this.tenDanhMuc,
    required this.hinhAnh,
  });

  factory DanhMucModel.fromJson(Map<String, dynamic> json) {
    return DanhMucModel(
      maDanhMuc: json['maDanhMuc']?.toString() ?? '',
      tenDanhMuc: json['tenDanhMuc']?.toString() ?? 'Không có tên',
      hinhAnh: json['hinhAnh']?.toString() ?? '',
    );
  }
}