// [file name]: screens/course_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/khoa_hoc_model.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

// MÀN HÌNH CHI TIẾT KHÓA HỌC - StatefulWidget vì có trạng thái đánh dấu, đăng ký
class CourseDetailScreen extends StatefulWidget {
  final KhoaHocModel khoaHoc; // Khóa học được truyền từ màn hình trước
  
  const CourseDetailScreen({
    super.key,
    required this.khoaHoc,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

// LỚP TRẠNG THÁI CỦA MÀN HÌNH CHI TIẾT KHÓA HỌC
class _CourseDetailScreenState extends State<CourseDetailScreen> {
  // BIẾN TRẠNG THÁI
  bool _isBookmarked = false;            // Trạng thái đánh dấu yêu thích
  KhoaHocModel? _detail;                 // Chi tiết khóa học (có thể null nếu chưa tải)
  bool _loadingDetail = false;           // Trạng thái đang tải chi tiết
  bool _isRegistered = false;            // Trạng thái đã đăng ký khóa học

  // KHỞI TẠO TRẠNG THÁI - GỌI KHI WIDGET ĐƯỢC TẠO
  @override
  void initState() {
    super.initState();
    _loadDetail();        // Tải chi tiết khóa học từ API
    _checkRegistered();   // Kiểm tra xem người dùng đã đăng ký chưa
  }

  // PHƯƠNG THỨC TẢI CHI TIẾT KHÓA HỌC TỪ API
  Future<void> _loadDetail() async {
    setState(() {
      _loadingDetail = true; // Bật trạng thái loading
    });
    
    // GỌI API LẤY THÔNG TIN CHI TIẾT KHÓA HỌC
    final res = await ApiService.layThongTinKhoaHoc(maKhoaHoc: widget.khoaHoc.maKhoaHoc);
    
    // KIỂM TRA NẾU WIDGET ĐÃ BỊ UNMOUNT (TRÁNH LỖI SETSTATE)
    if (!mounted) return;
    
    setState(() {
      _detail = res ?? _detail; // Gán kết quả, nếu null giữ nguyên
      _loadingDetail = false;   // Tắt trạng thái loading
    });
  }

  // PHƯƠNG THỨC KIỂM TRA XEM NGƯỜI DÙNG ĐÃ ĐĂNG KÝ KHÓA HỌC CHƯA
  Future<void> _checkRegistered() async {
    try {
      // LẤY DANH SÁCH KHÓA HỌC ĐÃ ĐĂNG KÝ CỦA NGƯỜI DÙNG
      final list = await ApiService.layKhoaHocGhiDanhCuaTaiKhoan();
      
      // KIỂM TRA XEM KHÓA HỌC HIỆN TẠI CÓ TRONG DANH SÁCH KHÔNG
      final exists = list.any((c) => c.maKhoaHoc == widget.khoaHoc.maKhoaHoc);
      
      if (!mounted) return; // Kiểm tra mounted
      
      setState(() {
        _isRegistered = exists; // Cập nhật trạng thái đăng ký
      });
    } catch (_) {
      // BẮT LỖI NHƯNG KHÔNG XỬ LÝ (CÓ THỂ LOG HOẶC HIỆN THÔNG BÁO)
    }
  }

  // PHƯƠNG THỨC XÂY DỰNG GIAO DIỆN CHÍNH
  @override
  Widget build(BuildContext context) {
    final course = _detail ?? widget.khoaHoc; // Ưu tiên dùng chi tiết, nếu không có dùng dữ liệu ban đầu
    
    return Scaffold(
      // SỬ DỤNG CUSTOMSCROLLVIEW ĐỂ CÓ HIỆU ỨNG CUỘN MƯỢT VỚI SLIVERAPPBAR
      body: CustomScrollView(
        slivers: [
          // APP BAR CÓ THỂ MỞ RỘNG (EXPANDABLE)
          SliverAppBar(
            expandedHeight: 250,  // Chiều cao khi mở rộng
            pinned: true,         // Giữ app bar khi cuộn
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // ẢNH NỀN KHÓA HỌC
                  course.hinhAnh.isNotEmpty
                      ? Image.network(
                          course.hinhAnh,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage(); // Fallback nếu ảnh lỗi
                          },
                        )
                      : _buildPlaceholderImage(), // Placeholder nếu không có ảnh
                  
                  // LỚP GRADIENT OVERLAY ĐỂ CHỮ DỄ ĐỌC
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7), // Đậm ở dưới
                          Colors.transparent,           // Trong suốt ở trên
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // TIÊU ĐỀ HIỂN THỊ TRÊN APP BAR
              title: Text(
                course.tenKhoaHoc,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // NÚT BACK Ở GÓC TRÁI
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            // CÁC NÚT HÀNH ĐỘNG Ở GÓC PHẢI
            actions: [
              // NÚT ĐÁNH DẤU YÊU THÍCH (BOOKMARK)
              IconButton(
                icon: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.white,
                ),
                onPressed: () {
                  // ĐẢO TRẠNG THÁI BOOKMARK
                  setState(() {
                    _isBookmarked = !_isBookmarked;
                  });
                  
                  // HIỂN THỊ THÔNG BÁO
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isBookmarked 
                          ? 'Đã thêm vào danh sách yêu thích' 
                          : 'Đã xóa khỏi danh sách yêu thích'),
                    ),
                  );
                },
              ),
            ],
          ),
          
          // NỘI DUNG CHÍNH CỦA MÀN HÌNH
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // THÔNG TIN CƠ BẢN (ĐÁNH GIÁ VÀ SỐ HỌC VIÊN)
                  Row(
                    children: [
                      // BADGE ĐÁNH GIÁ (RATING)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              course.danhGia,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // BADGE SỐ HỌC VIÊN
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.people, size: 16, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text(
                              '${course.soLuongHocVien} học viên',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // MÔ TẢ CHI TIẾT KHÓA HỌC
                  const Text(
                    'Mô tả khóa học',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    course.moTa,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // THÔNG TIN GIẢNG VIÊN
                  const Text(
                    'Thông tin giảng viên',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50], // Nền xám nhạt
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // AVATAR GIẢNG VIÊN (PLACEHOLDER)
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF6C63FF).withOpacity(0.1),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 30,
                            color: Color(0xFF6C63FF),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // THÔNG TIN GIẢNG VIÊN
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.getTenNguoiTao(), // Tên giảng viên
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Giảng viên', // Vai trò
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // THÔNG TIN BỔ SUNG VỀ KHÓA HỌC
                  const Text(
                    'Thông tin khóa học',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // CÁC MỤC THÔNG TIN CHI TIẾT
                  _buildInfoItem(
                    Icons.video_library,  // Icon
                    'Thời lượng',         // Tiêu đề
                    course.thoiLuong,     // Giá trị
                  ),
                  _buildInfoItem(
                    Icons.date_range,
                    'Ngày tạo',
                    course.ngayTao,
                  ),
                  _buildInfoItem(
                    Icons.remove_red_eye,
                    'Lượt xem',
                    course.luotXem,
                  ),
                  _buildInfoItem(
                    Icons.group,
                    'Mã nhóm',
                    course.maNhom,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // NÚT ĐĂNG KÝ Ở DƯỚI CÙNG
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              // XỬ LÝ KHI NHẤN NÚT ĐĂNG KÝ
              onPressed: _isRegistered ? null : () async { // Disable nếu đã đăng ký
                // LẤY THÔNG TIN NGƯỜI DÙNG TỪ PROVIDER
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final user = auth.user;
                
                // KIỂM TRA ĐĂNG NHẬP
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng đăng nhập để đăng ký')),
                  );
                  return;
                }
                
                try {
                  // GỌI API ĐĂNG KÝ KHÓA HỌC
                  await ApiService.dangKyKhoaHoc(
                    maKhoaHoc: course.maKhoaHoc,
                    taiKhoan: user.taiKhoan,
                  );
                  
                  if (!mounted) return; // Kiểm tra mounted
                  
                  // CẬP NHẬT TRẠNG THÁI ĐÃ ĐĂNG KÝ
                  setState(() {
                    _isRegistered = true;
                  });
                  
                  // HIỂN THỊ THÔNG BÁO THÀNH CÔNG
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đăng ký thành công: "${course.tenKhoaHoc}"'),
                      backgroundColor: Colors.green, // Màu xanh cho thành công
                    ),
                  );
                  
                  // ĐIỀU HƯỚNG ĐẾN TRANG TÀI KHOẢN VỚI THÔNG TIN
                  Navigator.pushNamed(
                    context,
                    '/account',
                    arguments: {
                      'section': 'myCourses',   // Mở tab khóa học của tôi
                      'registered': true,       // Đánh dấu đã đăng ký
                      'courseName': course.tenKhoaHoc, // Tên khóa học
                    },
                  );
                } catch (e) {
                  // XỬ LÝ LỖI ĐĂNG KÝ
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đăng ký thất bại: $e')),
                  );
                }
              },
              // TÙY CHỈNH KIỂU NÚT
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRegistered 
                    ? const Color(0xFF43A047)  // Màu xanh lá nếu đã đăng ký
                    : const Color(0xFF6C63FF), // Màu tím nếu chưa đăng ký
                foregroundColor: Colors.white, // Màu chữ trắng
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2, // Độ nổi
              ),
              // NỘI DUNG NÚT
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_checkout, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    _isRegistered ? 'ĐÃ ĐĂNG KÝ' : 'ĐĂNG KÝ NGAY',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET ẢNH PLACEHOLDER (KHI KHÔNG CÓ ẢNH HOẶC ẢNH LỖI)
  Widget _buildPlaceholderImage() {
    return Container(
      color: const Color(0xFF6C63FF).withOpacity(0.1), // Nền màu chủ đạo nhạt
      child: const Center(
        child: Icon(
          Icons.school,
          size: 80,
          color: Color(0xFF6C63FF), // Màu icon trùng với chủ đề
        ),
      ),
    );
  }

  // WIDGET HIỂN THỊ MỘT MỤC THÔNG TIN (ICON + TIÊU ĐỀ + GIÁ TRỊ)
  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey), // Icon
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TIÊU ĐỀ (NHỎ, MÀU XÁM)
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                // GIÁ TRỊ (LỚN HƠN, ĐẬM HƠN)
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}