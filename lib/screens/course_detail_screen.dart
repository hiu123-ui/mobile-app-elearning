// [file name]: screens/course_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/khoa_hoc_model.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class CourseDetailScreen extends StatefulWidget {
  final KhoaHocModel khoaHoc;
  
  const CourseDetailScreen({
    super.key,
    required this.khoaHoc,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool _isBookmarked = false;
  KhoaHocModel? _detail;
  bool _loadingDetail = false;
  bool _isRegistered = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
    _checkRegistered();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loadingDetail = true;
    });
    final res = await ApiService.layThongTinKhoaHoc(maKhoaHoc: widget.khoaHoc.maKhoaHoc);
    if (!mounted) return;
    setState(() {
      _detail = res ?? _detail;
      _loadingDetail = false;
    });
  }

  Future<void> _checkRegistered() async {
    try {
      final list = await ApiService.layKhoaHocGhiDanhCuaTaiKhoan();
      final exists = list.any((c) => c.maKhoaHoc == widget.khoaHoc.maKhoaHoc);
      if (!mounted) return;
      setState(() {
        _isRegistered = exists;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final course = _detail ?? widget.khoaHoc;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Ảnh nền khóa học
                  course.hinhAnh.isNotEmpty
                      ? Image.network(
                          course.hinhAnh,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        )
                      : _buildPlaceholderImage(),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isBookmarked = !_isBookmarked;
                  });
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
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thông tin cơ bản
                  Row(
                    children: [
                      // Rating
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
                      
                      // Số học viên
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
                  
                  // Mô tả chi tiết
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
                  
                  // Thông tin giảng viên
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
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.getTenNguoiTao(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Giảng viên',
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
                  
                  // Thông tin bổ sung
                  const Text(
                    'Thông tin khóa học',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  _buildInfoItem(
                    Icons.video_library,
                    'Thời lượng',
                    course.thoiLuong,
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
      
      // Nút đăng ký
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isRegistered ? null : () async {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final user = auth.user;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng đăng nhập để đăng ký')),
                  );
                  return;
                }
                try {
                  await ApiService.dangKyKhoaHoc(
                    maKhoaHoc: course.maKhoaHoc,
                    taiKhoan: user.taiKhoan,
                  );
                  if (!mounted) return;
                  setState(() {
                    _isRegistered = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đăng ký thành công: "${course.tenKhoaHoc}"'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pushNamed(
                    context,
                    '/account',
                    arguments: {
                      'section': 'myCourses',
                      'registered': true,
                      'courseName': course.tenKhoaHoc,
                    },
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đăng ký thất bại: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRegistered ? const Color(0xFF43A047) : const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
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

  Widget _buildPlaceholderImage() {
    return Container(
      color: const Color(0xFF6C63FF).withOpacity(0.1),
      child: const Center(
        child: Icon(
          Icons.school,
          size: 80,
          color: Color(0xFF6C63FF),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
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
