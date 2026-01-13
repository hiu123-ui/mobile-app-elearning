import 'package:flutter/material.dart';
import '../repositories/khoa_hoc_repository.dart';
import '../models/khoa_hoc_model.dart';
import '../widgets/khoa_hoc_card.dart';
import '../screens/courses_screen.dart';        
import '../screens/course_detail_screen.dart';   

// MÀN HÌNH TRANG CHỦ - StatefulWidget vì có dữ liệu động và trạng thái
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

// LỚP TRẠNG THÁI CỦA MÀN HÌNH TRANG CHỦ
class _HomeScreenState extends State<HomeScreen> {
  // KHAI BÁO BIẾN VÀ DỮ LIỆU
  final KhoaHocRepository _repository = KhoaHocRepository();  // Repository để lấy dữ liệu khóa học
  List<KhoaHocModel> _danhSachKhoaHoc = [];                   // Danh sách khóa học đầy đủ
  List<KhoaHocModel> _filteredHomeCourses = [];               // Danh sách khóa học đã lọc (hiện tại giống danh sách đầy đủ)
  bool _isLoading = true;                                     // Trạng thái đang tải dữ liệu
  String _errorMessage = '';                                  // Thông báo lỗi nếu có

  // PHƯƠNG THỨC KHỞI TẠO TRẠNG THÁI
  @override
  void initState() {
    super.initState();
    _loadAllCourses();  // Tải dữ liệu khóa học khi màn hình được khởi tạo
  }

  // PHƯƠNG THỨC TẢI TẤT CẢ KHÓA HỌC TỪ REPOSITORY
  Future<void> _loadAllCourses() async {
    setState(() {
      _isLoading = true;    // Bật trạng thái loading
      _errorMessage = '';   // Reset thông báo lỗi
    });

    try {
      final khoaHocList = await _repository.getDanhSachKhoaHoc();  // Gọi API/repository
      setState(() {
        _danhSachKhoaHoc = khoaHocList;          // Lưu danh sách đầy đủ
        _filteredHomeCourses = khoaHocList;      // Gán cho danh sách hiển thị
        _isLoading = false;                      // Tắt trạng thái loading
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải dữ liệu. Vui lòng thử lại!';  // Xử lý lỗi
        _isLoading = false;
      });
    }
  }

  // DỮ LIỆU TĨNH - THÔNG TIN CÁC DANH MỤC KHÓA HỌC
  // Map chứa thông tin hiển thị cho từng danh mục
  static const Map<String, Map<String, dynamic>> _categoryData = {
    'frontend': {
      'title': 'Lập Trình Frontend',
      'subtitle': 'HTML, CSS, JavaScript, React, Vue.js, Angular và các framework hiện đại',
      'icon': Icons.code_rounded,
      'color': Color(0xFF6C63FF),  // Màu chủ đạo của danh mục
      'image': 'https://tse1.mm.bing.net/th/id/OIP.KnzMtsMOM8yG0Fx8pNLBYQHaEf?pid=Api&P=0&h=220',
    },
    'backend': {
      'title': 'Lập Trình Backend',
      'subtitle': 'Node.js, Python, Java, PHP, C#, Database, API và hệ thống server',
      'icon': Icons.storage_rounded,
      'color': Color(0xFF4CAF50),
      'image': 'https://canhme.com/wp-content/uploads/2018/09/Nodejs.png',
    },
    'fullstack': {
      'title': 'Lập Trình Fullstack',
      'subtitle': 'Master cả Frontend và Backend, xây dựng ứng dụng hoàn chỉnh từ A-Z',
      'icon': Icons.all_inclusive_rounded,
      'color': Color(0xFFFF9800),
      'image': 'https://tse4.mm.bing.net/th/id/OIP.tx5zOJG8j8o3Ke6-UTK3TAHaDf?pid=Api&P=0&h=220',
    },
    'DiDong': {
      'title': 'Lập Trình Di Động',
      'subtitle': 'React Native, Flutter, iOS, Android, xây dựng ứng dụng mobile chuyên nghiệp',
      'icon': Icons.phone_android_rounded,
      'color': Color(0xFF2196F3),
      'image': 'https://tse2.mm.bing.net/th/id/OIP.UzgaU4gKG_GkXhlHigItPQHaEK?pid=Api&P=0&h=220',
    },
  };

  // DỮ LIỆU TĨNH - DANH SÁCH GIẢNG VIÊN
  static const List<Map<String, dynamic>> _giangVienList = [
    {
      'name': 'Nguyễn Văn A',
      'position': 'Chuyên gia Frontend',
      'experience': '8 năm kinh nghiệm',
      'image': 'https://tse3.mm.bing.net/th/id/OIP.7mY0eAdnoXy5e_Et8o6GJQHaE8?pid=Api&P=0&h=220',
      'courses': 12,  // Số khóa học đã dạy
    },
    {
      'name': 'Nguyễn Văn B',
      'position': 'Chuyên gia Backend',
      'experience': '8 năm kinh nghiệm',
      'image': 'https://tse3.mm.bing.net/th/id/OIP.7mY0eAdnoXy5e_Et8o6GJQHaE8?pid=Api&P=0&h=220',
      'courses': 12,  
    },{
      'name': 'Nguyễn Văn C',
      'position': 'Chuyên gia Fullstack',
      'experience': '8 năm kinh nghiệm',
      'image': 'https://tse3.mm.bing.net/th/id/OIP.7mY0eAdnoXy5e_Et8o6GJQHaE8?pid=Api&P=0&h=220',
      'courses': 12, 
    }
  ];

  // WIDGET HIỂN THỊ THẺ DANH MỤC
  Widget _buildCategoryCard(String key) {
    final data = _categoryData[key]!;  // Lấy dữ liệu danh mục từ key,đảm bảo thực sự không null để tránh crash
    return GestureDetector(
      onTap: () {
        // Điều hướng đến màn hình danh sách khóa học với danh mục được chọn
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CoursesScreen(initialCategoryName: key),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        height: 180,
        decoration: BoxDecoration(
          
          image: DecorationImage(
            image: NetworkImage(data['image']),  // Ảnh nền từ URL
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.45),  // Lớp phủ tối để chữ dễ đọc
              BlendMode.darken,
            ),
          ),
        ),
        child: Stack(
          children: [
            // Icon danh mục
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: data['color'].withOpacity(0.9),  // Màu nền icon
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(data['icon'], color: Colors.white, size: 36),
              ),
            ),
            // Tiêu đề và mô tả danh mục
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data['subtitle'],
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Icon mũi tên điều hướng
            const Positioned(
              top: 20,
              right: 20,
              child: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  // PHƯƠNG THỨC XÂY DỰNG GIAO DIỆN CHÍNH
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(  // Sử dụng CustomScrollView cho hiệu ứng cuộn mượt
        slivers: [
          // APP BAR CỐ ĐỊNH
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            floating: true,
            pinned: true,  // AppBar cố định khi cuộn
            title: const Text(
              'E-LEARNING',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C63FF),  // Màu chủ đạo của app
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: Colors.grey[700]),
                onPressed: () {},  // Chức năng thông báo (chưa implement)
              ),
              const SizedBox(width: 8),
            ],
          ),

          // PHẦN HERO (BANNER GIỚI THIỆU)
          SliverToBoxAdapter(child: _buildHeroSection()),

          // DANH SÁCH CÁC DANH MỤC KHÓA HỌC
          SliverToBoxAdapter(child: _buildCategoryCard('frontend')),
          SliverToBoxAdapter(child: _buildCategoryCard('backend')),
          SliverToBoxAdapter(child: _buildCategoryCard('fullstack')),
          SliverToBoxAdapter(child: _buildCategoryCard('DiDong')),

          // TIÊU ĐỀ KHÓA HỌC NỔI BẬT
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Khóa Học Nổi Bật',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cập nhật những khóa học hot nhất giúp bạn chinh phục lập trình.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // DANH SÁCH KHÓA HỌC NỔI BẬT (DẠNG NGANG)
          _buildKhoaHocList(),

          // PHẦN ĐỘI NGŨ GIẢNG VIÊN
          SliverToBoxAdapter(child: _buildGiangVienSection()),

          // FOOTER (CHÂN TRANG)
          SliverToBoxAdapter(child: _buildFooter()),
        ],
      ),
      // THANH ĐIỀU HƯỚNG DƯỚI CÙNG
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // WIDGET PHẦN HERO (BANNER GIỚI THIỆU CHÍNH)
  Widget _buildHeroSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2563EB).withOpacity(0.15),
            const Color(0xFF38BDF8).withOpacity(0.08),
          ],
        ),
        
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TIÊU ĐỀ CHÍNH VỚI TEXTSPAN
          RichText(
            text: TextSpan(
              style: const TextStyle(fontFamily: 'Roboto'),
              children: [
                const TextSpan(
                  text: 'Khám Phá Thế Giới Lập Trình',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // MÔ TẢ
          Text(
            'Nâng tầm kỹ năng với hơn 100+ khóa học chất lượng cao từ cơ bản đến nâng cao',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.grey[700],
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),

          // THỐNG KÊ (GIỜ HỌC, KHÓA HỌC, HỌC VIÊN)
          SizedBox(
            height: 60,
            child: SingleChildScrollView(  // Cuộn ngang nếu không đủ chỗ
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatItem(Icons.play_circle_filled, '500+', 'Giờ học'),
                  const SizedBox(width: 24),
                  _buildStatItem(Icons.school, '50+', 'Khóa học'),
                  const SizedBox(width: 24),
                  _buildStatItem(Icons.people, '10K+', 'Học viên'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // NÚT HÀNH ĐỘNG CHÍNH - Responsive layout
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 400) {  // Màn hình nhỏ: xếp dọc
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPrimaryButton(),
                    const SizedBox(height: 12),
                    _buildSecondaryButton(),
                  ],
                );
              } else {  // Màn hình lớn: xếp ngang
                return Row(
                  children: [
                    _buildPrimaryButton(),
                    const SizedBox(width: 16),
                    _buildSecondaryButton(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // NÚT CHÍNH (MÀU ĐẬM)
  Widget _buildPrimaryButton() {
    return ElevatedButton.icon(
      onPressed: () {},  // Chức năng khám phá (chưa implement)
      icon: const Icon(Icons.explore, size: 20),
      label: const Text(
        'Khám Phá Ngay',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6C63FF),  // Màu nền chủ đạo
        foregroundColor: Colors.white,             // Màu chữ trắng
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 6,
        minimumSize: const Size(160, 50),
      ),
    );
  }

  // NÚT PHỤ (VIỀN)
  Widget _buildSecondaryButton() {
    return OutlinedButton.icon(
      onPressed: () {},  // Chức năng xem giới thiệu (chưa implement)
      icon: const Icon(Icons.ondemand_video, color: Color(0xFF6C63FF)),
      label: const Text(
        'Xem Giới Thiệu',
        style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        side: const BorderSide(color: Color(0xFF6C63FF), width: 2),  // Viền màu chủ đạo
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        minimumSize: const Size(160, 50),
      ),
    );
  }

  // WIDGET HIỂN THỊ THỐNG KÊ (ICON + SỐ + NHÃN)
  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28, color: const Color(0xFF6C63FF)),  // Icon màu chủ đạo
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,  // Số liệu thống kê
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              label,  // Nhãn thống kê
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  // PHẦN ĐỘI NGŨ GIẢNG VIÊN
  Widget _buildGiangVienSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2563EB).withOpacity(0.15),
            const Color(0xFF38BDF8).withOpacity(0.08),
          ],
        ),
        
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TIÊU ĐỀ PHẦN GIẢNG VIÊN
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Đội Ngũ Giảng Viên',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              // BADGE SỐ LƯỢNG GIẢNG VIÊN
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_giangVienList.length} giảng viên',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6C63FF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // MÔ TẢ PHẦN GIẢNG VIÊN
          Text(
            'Học cùng chuyên gia hàng đầu với nhiều năm kinh nghiệm',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // DANH SÁCH GIẢNG VIÊN
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _giangVienList.length,
              itemBuilder: (context, index) {
                final giangVien = _giangVienList[index];
                return Container(
                  width: 200,
                  margin: EdgeInsets.only(
                    right: index < _giangVienList.length - 1 ? 20 : 0,
                  ),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ẢNH GIẢNG VIÊN (HÌNH TRÒN)
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF6C63FF).withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.network(
                                giangVien['image'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(  // Icon fallback nếu ảnh lỗi
                                    Icons.person,
                                    size: 50,
                                    color: Color(0xFF6C63FF),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // TÊN GIẢNG VIÊN
                          Text(
                            giangVien['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          // CHỨC VỤ
                          Text(
                            giangVien['position'],
                            style: TextStyle(
                              fontSize: 13,
                              color: const Color(0xFF6C63FF),
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          // KINH NGHIỆM
                          Text(
                            giangVien['experience'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          // SỐ KHÓA HỌC ĐÃ DẠY
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${giangVien['courses']} khóa học',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // PHẦN FOOTER (CHÂN TRANG)
  Widget _buildFooter() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6C63FF).withOpacity(0.9),  // Gradient màu chủ đạo
            const Color(0xFF6C63FF).withOpacity(0.7),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
        child: Column(
          children: [
            // LOGO VÀ MÔ TẢ ỨNG DỤNG
            const Column(
              children: [
                Text(
                  'E-LEARNING',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Nền tảng học lập trình trực tuyến hàng đầu Việt Nam',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // THÔNG TIN LIÊN HỆ
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildFooterItem(Icons.email, 'support@elearning.com'),
                const SizedBox(height: 16),
                _buildFooterItem(Icons.phone, '1234 5678'),
                const SizedBox(height: 16),
                _buildFooterItem(Icons.location_on, 'Nhóm 4'),
              ],
            ),
            const SizedBox(height: 24),

            // CÓ THỂ THÊM CÁC PHẦN KHÁC NHƯ: SOCIAL ICONS, LINKS, COPYRIGHT...
          ],
        ),
      ),
    );
  }

  // WIDGET HIỂN THỊ MỘT MỤC TRONG FOOTER
  Widget _buildFooterItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // XÂY DỰNG DANH SÁCH KHÓA HỌC NỔI BẬT
  Widget _buildKhoaHocList() {
    // TRẠNG THÁI LOADING: Hiển thị skeleton
    if (_isLoading) {
      return SliverToBoxAdapter(child: _buildLoadingCourses());
    }
    
    // TRẠNG THÁI LỖI: Hiển thị thông báo lỗi và nút thử lại
    if (_errorMessage.isNotEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadAllCourses,  // Nút thử lại tải dữ liệu
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }
    
    // TRẠNG THÁI DANH SÁCH RỖNG
    if (_danhSachKhoaHoc.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text('Không có khóa học nào'),
            ],
          ),
        ),
      );
    }

    // TRẠNG THÁI CÓ DỮ LIỆU: Hiển thị danh sách khóa học
    return SliverToBoxAdapter(child: _buildCoursesHorizontalList());
  }

  // DANH SÁCH KHÓA HỌC DẠNG NGANG
  Widget _buildCoursesHorizontalList() {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredHomeCourses.length,
        itemBuilder: (context, index) {
          final khoaHoc = _filteredHomeCourses[index];
          return Container(
            width: 240,
            margin: EdgeInsets.only(
              right: index < _filteredHomeCourses.length - 1 ? 16 : 0,
            ),
            child: KhoaHocCard(  // Widget custom hiển thị thông tin khóa học
              khoaHoc: khoaHoc,
              onTap: () => _showCourseDetail(khoaHoc),  // Xử lý khi nhấn vào khóa học
            ),
          );
        },
      ),
    );
  }

  // SKELETON LOADING CHO KHÓA HỌC
  Widget _buildLoadingCourses() {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,  // Hiển thị 4 skeleton items
        itemBuilder: (context, index) {
          return Container(
            width: 240,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(height: 140, color: Colors.grey[200]),  // Skeleton cho ảnh
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Skeleton cho tiêu đề
                      SizedBox(
                        height: 20,
                        width: double.infinity,
                        child: ColoredBox(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      // Skeleton cho mô tả
                      SizedBox(
                        height: 40,
                        width: double.infinity,
                        child: ColoredBox(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // THANH ĐIỀU HƯỚNG DƯỚI CÙNG
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0,  // Trang chủ đang được chọn
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF6C63FF),  // Màu khi được chọn
      unselectedItemColor: Colors.grey[600],       // Màu khi không được chọn
      // XỬ LÝ KHI NHẤN VÀO CÁC MỤC
      onTap: (index) {
        if (index == 1) {
          Navigator.pushNamed(context, '/courses');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/blog');
        } else if (index == 3) {
          Navigator.pushNamed(context, '/account');
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          activeIcon: Icon(Icons.menu_book),
          label: 'Khóa học',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.rss_feed_outlined),
          activeIcon: Icon(Icons.rss_feed),
          label: 'Bài viết',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Tài khoản',
        ),
      ],
    );
  }

  // DỌN DẸP TÀI NGUYÊN KHI WIDGET BỊ HỦY
  @override
  void dispose() {
    super.dispose();
    // Có thể thêm các thao tác dọn dẹp nếu cần
  }

  // PHƯƠNG THỨC HIỂN THỊ CHI TIẾT KHÓA HỌC
  void _showCourseDetail(KhoaHocModel khoaHoc) {
    // Điều hướng đến màn hình chi tiết khóa học với dữ liệu được truyền qua arguments
    Navigator.pushNamed(context, '/course-detail', arguments: khoaHoc);
  }
}
