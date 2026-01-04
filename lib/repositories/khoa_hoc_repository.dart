import '../models/danh_muc_model.dart';
import '../models/khoa_hoc_model.dart';
import '../services/api_service.dart';

class KhoaHocRepository {
  // 1. Lấy danh sách danh mục khóa học
  Future<List<DanhMucModel>> getDanhSachDanhMuc({String? tenDanhMuc}) async {
    try {
      final categories = await ApiService.layDanhMucKhoaHoc(tenDanhMuc: tenDanhMuc);
      return categories;
    } catch (e) {
      print('Error in getDanhSachDanhMuc: $e');
      return [];
    }
  }

  // 2. Lấy danh sách tất cả khóa học
  Future<List<KhoaHocModel>> getDanhSachKhoaHoc({String? tenKhoaHoc}) async {
    try {
      final data = await ApiService.layDanhSachKhoaHoc(tenKhoaHoc: tenKhoaHoc);
      return data.map((item) => KhoaHocModel.fromJson(item)).toList();
    } catch (e) {
      print('Error in getDanhSachKhoaHoc: $e');
      return [];
    }
  }

  // 3. Lấy khóa học theo danh mục - PHƯƠNG THỨC MỚI
  Future<List<KhoaHocModel>> getKhoaHocTheoDanhMuc({required String maDanhMuc}) async {
    try {
      final data = await ApiService.layKhoaHocTheoDanhMuc(maDanhMuc: maDanhMuc);
      return data.map((item) => KhoaHocModel.fromJson(item)).toList();
    } catch (e) {
      print('Error in getKhoaHocTheoDanhMuc: $e');
      throw Exception('Không thể tải khóa học theo danh mục');
    }
  }

  // 4. Tìm kiếm khóa học
  Future<List<KhoaHocModel>> timKiemKhoaHoc(String query) async {
    try {
      final allCourses = await getDanhSachKhoaHoc();
      return allCourses.where((course) {
        return course.tenKhoaHoc.toLowerCase().contains(query.toLowerCase()) ||
               course.moTa.toLowerCase().contains(query.toLowerCase()) ||
               course.getTenNguoiTao().toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      print('Error in timKiemKhoaHoc: $e');
      return [];
    }
  }

  // 5. Lấy khóa học nổi bật (theo đánh giá cao)
  Future<List<KhoaHocModel>> getKhoaHocNoiBat({int limit = 10}) async {
    try {
      final allCourses = await getDanhSachKhoaHoc();
      allCourses.sort((a, b) => b.danhGia.compareTo(a.danhGia));
      return allCourses.take(limit).toList();
    } catch (e) {
      print('Error in getKhoaHocNoiBat: $e');
      return [];
    }
  }

  // 6. Lấy khóa học mới nhất
  Future<List<KhoaHocModel>> getKhoaHocMoiNhat({int limit = 10}) async {
    try {
      final allCourses = await getDanhSachKhoaHoc();
      // Sắp xếp theo ngày tạo (giả sử có trường ngayTao)
      // allCourses.sort((a, b) => b.ngayTao.compareTo(a.ngayTao));
      return allCourses.take(limit).toList();
    } catch (e) {
      print('Error in getKhoaHocMoiNhat: $e');
      return [];
    }
  }
}