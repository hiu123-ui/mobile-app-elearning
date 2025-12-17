// [file name]: repositories/khoa_hoc_repository.dart
import '../models/khoa_hoc_model.dart';
import '../services/api_service.dart';
import '../models/danh_muc_model.dart';

class KhoaHocRepository {
  // Lấy danh sách danh mục khóa học (giữ nguyên)
  Future<List<DanhMucModel>> getDanhSachDanhMuc({
    String? tenDanhMuc,
  }) async {
    try {
      final data = await ApiService.layDanhMucKhoaHoc(
        tenDanhMuc: tenDanhMuc,
      );
      return data;
    } catch (e) {
      print('Repository Error (DanhMuc): $e');
      rethrow;
    }
  }
  
  // Lấy danh sách khóa học (giữ nguyên)
  Future<List<KhoaHocModel>> getDanhSachKhoaHoc({
    String? tenKhoaHoc,
    String maNhom = 'GP01',
  }) async {
    try {
      final data = await ApiService.layDanhSachKhoaHoc(
        tenKhoaHoc: tenKhoaHoc,
        maNhom: maNhom,
      );
      
      return data.map<KhoaHocModel>((item) {
        return KhoaHocModel.fromJson(item);
      }).toList();
    } catch (e) {
      print('Repository Error: $e');
      rethrow;
    }
  }

  // Lấy khóa học theo danh mục - PHƯƠNG THỨC MỚI
  Future<List<KhoaHocModel>> getKhoaHocTheoDanhMuc({
    required String maDanhMuc,
    String maNhom = 'GP01',
  }) async {
    try {
      final data = await ApiService.layKhoaHocTheoDanhMuc(
        maDanhMuc: maDanhMuc,
        maNhom: maNhom,
      );
      
      return data.map<KhoaHocModel>((item) {
        return KhoaHocModel.fromJson(item);
      }).toList();
    } catch (e) {
      print('Repository Error (KhoaHocTheoDanhMuc): $e');
      rethrow;
    }
  }
}