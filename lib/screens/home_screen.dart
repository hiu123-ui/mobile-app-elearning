// [file name]: screens/home_screen.dart
import 'package:flutter/material.dart';
import '../repositories/khoa_hoc_repository.dart';
import '../models/khoa_hoc_model.dart';
import '../widgets/khoa_hoc_card.dart';
import 'courses_screen.dart';        // <-- Thêm dòng này
import 'course_detail_screen.dart';   // <-- Thêm dòng này (nếu chưa có)
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final KhoaHocRepository _repository = KhoaHocRepository();
  List<KhoaHocModel> _danhSachKhoaHoc = [];
  List<KhoaHocModel> _filteredHomeCourses = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadAllCourses();
  }

  Future<void> _loadAllCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final khoaHocList = await _repository.getDanhSachKhoaHoc();
      setState(() {
        _danhSachKhoaHoc = khoaHocList;
        _filteredHomeCourses = khoaHocList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải dữ liệu. Vui lòng thử lại!';
        _isLoading = false;
      });
    }
  }

  // Map ảnh nền cho từng danh mục
  static const Map<String, Map<String, dynamic>> _categoryData = {
    'frontend': {
      'title': 'Lập Trình Frontend',
      'subtitle':
          'HTML, CSS, JavaScript, React, Vue.js, Angular và các framework hiện đại',
      'icon': Icons.code_rounded,
      'color': Color(0xFF6C63FF),
      'image':
          'https://tse1.mm.bing.net/th/id/OIP.KnzMtsMOM8yG0Fx8pNLBYQHaEf?pid=Api&P=0&h=220',
    },
    'backend': {
      'title': 'Lập Trình Backend',
      'subtitle':
          'Node.js, Python, Java, PHP, C#, Database, API và hệ thống server',
      'icon': Icons.storage_rounded,
      'color': Color(0xFF4CAF50),
      'image':
          'https://canhme.com/wp-content/uploads/2018/09/Nodejs.png',
    },
    'fullstack': {
      'title': 'Lập Trình Fullstack',
      'subtitle':
          'Master cả Frontend và Backend, xây dựng ứng dụng hoàn chỉnh từ A-Z',
      'icon': Icons.all_inclusive_rounded,
      'color': Color(0xFFFF9800),
      'image':
          'https://tse4.mm.bing.net/th/id/OIP.tx5zOJG8j8o3Ke6-UTK3TAHaDf?pid=Api&P=0&h=220',
    },
    'DiDong': {
      'title': 'Lập Trình Di Động',
      'subtitle':
          'React Native, Flutter, iOS, Android, xây dựng ứng dụng mobile chuyên nghiệp',
      'icon': Icons.phone_android_rounded,
      'color': Color(0xFF2196F3),
      'image':
          'https://tse2.mm.bing.net/th/id/OIP.UzgaU4gKG_GkXhlHigItPQHaEK?pid=Api&P=0&h=220',
    },
  };

  // Danh sách giảng viên (code cứng)
  static const List<Map<String, dynamic>> _giangVienList = [
    {
      'name': 'Nguyễn Văn An',
      'position': 'Chuyên gia Frontend',
      'experience': '8 năm kinh nghiệm',
      'image':
          'https://tse3.mm.bing.net/th/id/OIP.7mY0eAdnoXy5e_Et8o6GJQHaE8?pid=Api&P=0&h=220',
      'courses': 12,
    },
    {
      'name': 'Trần Thị Bích',
      'position': 'Chuyên gia Backend',
      'experience': '10 năm kinh nghiệm',
      'image':
          'https://tse2.mm.bing.net/th/id/OIP.9LQAn7R4f2w5rxrjELv_swHaE7?pid=Api&P=0&h=220',
      'courses': 15,
    },
    {
      'name': 'Lê Minh Cường',
      'position': 'Chuyên gia Fullstack',
      'experience': '7 năm kinh nghiệm',
      'image':
          'https://tse1.mm.bing.net/th/id/OIP.Q57w8v1q0YWG5ffRje3b5gHaE8?pid=Api&P=0&h=220',
      'courses': 18,
    },
    {
      'name': 'Phạm Di Động',
      'position': 'Chuyên gia Mobile',
      'experience': '6 năm kinh nghiệm',
      'image':
          'https://tse2.mm.bing.net/th/id/OIP.Jk2I6eS-IA8N_EvyGlT8qwHaE8?pid=Api&P=0&h=220',
      'courses': 10,
    },
  ];

  Widget _buildCategoryCard(String key) {
    final data = _categoryData[key]!;
    return GestureDetector(
      onTap: () {
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
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(data['image']),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.45),
              BlendMode.darken,
            ),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: data['color'].withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(data['icon'], color: Colors.white, size: 36),
              ),
            ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            floating: true,
            pinned: true,
            title: const Text(
              'E-LEARNING',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C63FF),
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: Colors.grey[700]),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),

          SliverToBoxAdapter(child: _buildHeroSection()),

          SliverToBoxAdapter(child: _buildCategoryCard('frontend')),
          SliverToBoxAdapter(child: _buildCategoryCard('backend')),
          SliverToBoxAdapter(child: _buildCategoryCard('fullstack')),
          SliverToBoxAdapter(child: _buildCategoryCard('DiDong')),

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

          _buildKhoaHocList(),

          // ĐỘI NGŨ GIẢNG VIÊN
          SliverToBoxAdapter(child: _buildGiangVienSection()),

          // FOOTER - Sửa padding và margin để không dư khoảng trắng
          SliverToBoxAdapter(child: _buildFooter()),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  

  Widget _buildHeroSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6C63FF).withOpacity(0.15),
            const Color(0xFF6C63FF).withOpacity(0.08),
            Colors.white.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
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
          RichText(
            text: TextSpan(
              style: const TextStyle(fontFamily: 'Roboto'),
              children: [
                const TextSpan(
                  text: 'Khám Phá Thế Giới ',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                TextSpan(
                  text: 'Lập Trình',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF6C63FF),
                  ),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

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

          SizedBox(
            height: 60,
            child: SingleChildScrollView(
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

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 400) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPrimaryButton(),
                    const SizedBox(height: 12),
                    _buildSecondaryButton(),
                  ],
                );
              } else {
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

  Widget _buildPrimaryButton() {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.explore, size: 20),
      label: const Text(
        'Khám Phá Ngay',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 6,
        minimumSize: const Size(160, 50),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.ondemand_video, color: Color(0xFF6C63FF)),
      label: const Text(
        'Xem Giới Thiệu',
        style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        side: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        minimumSize: const Size(160, 50),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28, color: const Color(0xFF6C63FF)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              label,
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
            const Color(0xFF6C63FF).withOpacity(0.05),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Text(
            'Học cùng chuyên gia hàng đầu với nhiều năm kinh nghiệm',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Danh sách giảng viên
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
                          // Ảnh giảng viên
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
                                  return const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Color(0xFF6C63FF),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Tên giảng viên
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
                          // Chức vụ
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
                          // Kinh nghiệm
                          Text(
                            giangVien['experience'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          // Số khóa học
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
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

  // PHẦN FOOTER - ĐÃ SỬA: loại bỏ margin top và padding dư thừa
  Widget _buildFooter() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6C63FF).withOpacity(0.9),
            const Color(0xFF6C63FF).withOpacity(0.7),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
        child: Column(
          children: [
            // Logo và mô tả - Sửa theo hình
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

            // Thông tin liên hệ - Sửa theo hình
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildFooterItem(Icons.email, 'support@elearning.com'),
                const SizedBox(height: 16),
                _buildFooterItem(Icons.phone, '1900 1234'),
                const SizedBox(height: 16),
                _buildFooterItem(Icons.location_on, 'Nhóm 4'),
              ],
            ),
            const SizedBox(height: 24),

          ],
        ),
      ),
    );
  }

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

  Widget _buildKhoaHocList() {
    if (_isLoading) {
      return SliverToBoxAdapter(child: _buildLoadingCourses());
    }
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
                onPressed: _loadAllCourses,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }
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

    return SliverToBoxAdapter(child: _buildCoursesHorizontalList());
  }

  Widget _buildCoursesHorizontalList() {
    return SizedBox(
      height: 340,
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
            child: KhoaHocCard(
              khoaHoc: khoaHoc,
              onTap: () => _showCourseDetail(khoaHoc),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingCourses() {
    return SizedBox(
      height: 340,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
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
                Container(height: 140, color: Colors.grey[200]),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                        width: double.infinity,
                        child: ColoredBox(color: Colors.grey),
                      ),
                      SizedBox(height: 8),
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

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF6C63FF),
      unselectedItemColor: Colors.grey[600],
      // THÊM onTap ĐỂ ĐIỀU HƯỚNG
      onTap: (index) {
        if (index == 1) {
          // Tab "Khóa học" (index = 1)
          Navigator.pushNamed(context, '/courses');
        }
        // Các tab khác có thể thêm sau (Danh mục, Blog, Tài khoản...)
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
          icon: Icon(Icons.category_outlined),
          activeIcon: Icon(Icons.category),
          label: 'Danh mục',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.rss_feed_outlined),
          activeIcon: Icon(Icons.rss_feed),
          label: 'Blog',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Tài khoản',
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showCourseDetail(KhoaHocModel khoaHoc) {
    Navigator.pushNamed(context, '/course-detail', arguments: khoaHoc);
  }
}
