import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../models/danh_muc_model.dart';
import '../models/khoa_hoc_model.dart';
import '../repositories/khoa_hoc_repository.dart';
import '../widgets/khoa_hoc_card.dart';
import './course_detail_screen.dart';

// MÀN HÌNH DANH SÁCH KHÓA HỌC - StatefulWidget để quản lý trạng thái tải và lọc
class CoursesScreen extends StatefulWidget {
  final String? initialCategoryName; // Danh mục ban đầu được truyền từ màn hình khác
  const CoursesScreen({super.key, this.initialCategoryName});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

// LỚP TRẠNG THÁI CỦA MÀN HÌNH DANH SÁCH KHÓA HỌC
class _CoursesScreenState extends State<CoursesScreen> {
  // REPOSITORY VÀ BIẾN QUẢN LÝ DỮ LIỆU
  final KhoaHocRepository _repository = KhoaHocRepository();

  // TRẠNG THÁI (STATE) CỦA MÀN HÌNH
  List<DanhMucModel> _danhMucList = [];         // Danh sách tất cả danh mục
  List<KhoaHocModel> _allCourses = [];          // Danh sách tất cả khóa học
  List<KhoaHocModel> _filteredCourses = [];     // Danh sách khóa học đã lọc theo danh mục/tìm kiếm
  bool _isLoading = true;                       // Trạng thái đang tải dữ liệu chính
  String _errorMessage = '';                    // Thông báo lỗi nếu có
  int _selectedCategoryIndex = 0;               // Chỉ số danh mục được chọn (0 = Tất cả)
  bool _isLoadingCategory = false;              // Trạng thái đang tải khóa học theo danh mục
  bool _showSearchBar = false;                  // Trạng thái hiển thị thanh tìm kiếm

  // BIẾN QUẢN LÝ TÌM KIẾM
  final TextEditingController _searchController = TextEditingController(); // Controller cho ô tìm kiếm
  String _searchQuery = '';                      // Từ khóa tìm kiếm hiện tại
  final FocusNode _searchFocusNode = FocusNode(); // FocusNode để điều khiển focus của ô tìm kiếm

  // MAP ẢNH MẶC ĐỊNH THEO DANH MỤC (dùng khi khóa học không có ảnh)
  final Map<String, String> _imageByCategory = {
    'frontend': 'https://tse1.mm.bing.net/th/id/OIP.KnzMtsMOM8yG0Fx8pNLBYQHaEf?pid=Api&P=0&h=220',
    'backend': 'https://canhme.com/wp-content/uploads/2018/09/Nodejs.png',
    'fullstack': 'https://tse4.mm.bing.net/th/id/OIP.tx5zOJG8j8o3Ke6-UTK3TAHaDf?pid=Api&P=0&h=220',
    'didong': 'https://tse2.mm.bing.net/th/id/OIP.UzgaU4gKG_GkXhlHigItPQHaEK?pid=Api&P=0&h=220',
  };

  // PHƯƠNG THỨC LẤY ẢNH CHO KHÓA HỌC
  // Logic: Ưu tiên lấy ảnh theo danh mục → tìm trong tên khóa học/mô tả → dùng ảnh của khóa học nếu có
  String? _getCourseImage(KhoaHocModel c) {
    String? url;
    
    // THỬ LẤY ẢNH THEO DANH MỤC ĐƯỢC CHỌN
    if (_selectedCategoryIndex > 0 && _selectedCategoryIndex - 1 < _danhMucList.length) {
      final cat = _danhMucList[_selectedCategoryIndex - 1].tenDanhMuc.toLowerCase();
      final catNorm = cat.replaceAll(' ', ''); // Chuẩn hóa: bỏ khoảng trắng
      
      // Kiểm tra các từ khóa danh mục để lấy ảnh phù hợp
      if (catNorm.contains('frontend')) url = _imageByCategory['frontend'];
      if (catNorm.contains('backend')) url = _imageByCategory['backend'];
      if (catNorm.contains('fullstack')) url = _imageByCategory['fullstack'];
      if (cat.contains('di động') || cat.contains('di dong') || catNorm.contains('didong') || cat.contains('mobile')) {
        url = _imageByCategory['didong'];
      }
    }
    
    // NẾU CHƯA CÓ ẢNH, TÌM TRONG TÊN KHÓA HỌC VÀ MÔ TẢ
    if (url == null) {
      final s = ('${c.tenKhoaHoc} ${c.moTa}').toLowerCase();
      final sNorm = s.replaceAll(' ', '');
      
      if (sNorm.contains('frontend')) url = _imageByCategory['frontend'];
      if (sNorm.contains('backend')) url = _imageByCategory['backend'];
      if (sNorm.contains('fullstack')) url = _imageByCategory['fullstack'];
      if (s.contains('di động') || s.contains('di dong') || sNorm.contains('didong') || s.contains('mobile')) {
        url = _imageByCategory['didong'];
      }
    }
    
    // NẾU VẪN CHƯA CÓ, TRẢ VỀ ẢNH CỦA KHÓA HỌC HOẶC NULL
    return url ?? (c.hinhAnh.isNotEmpty ? c.hinhAnh : null);
  }

  // KHỞI TẠO TRẠNG THÁI - GỌI KHI WIDGET ĐƯỢC TẠO
  @override
  void initState() {
    super.initState();
    _loadData(); // Tải dữ liệu ban đầu
  }

  // PHƯƠNG THỨC TẢI DỮ LIỆU CHÍNH (danh mục và khóa học)
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 1. TẢI DANH SÁCH DANH MỤC
      final categories = await _repository.getDanhSachDanhMuc();
      
      // 2. TẢI DANH SÁCH TẤT CẢ KHÓA HỌC
      final courses = await _repository.getDanhSachKhoaHoc();
      
      setState(() {
        _danhMucList = categories;
        _allCourses = courses;
        _filteredCourses = courses; // Ban đầu hiển thị tất cả
        _isLoading = false;
      });
      
      // 3. XỬ LÝ DANH MỤC BAN ĐẦU NẾU ĐƯỢC TRUYỀN TỪ MÀN HÌNH TRƯỚC
      if (widget.initialCategoryName != null && widget.initialCategoryName!.trim().isNotEmpty) {
        final kw = widget.initialCategoryName!.toLowerCase();
        final kwNoSpace = kw.replaceAll(' ', '');
        
        // TÌM DANH MỤC PHÙ HỢP VỚI TÊN ĐƯỢC TRUYỀN
        int idx = _danhMucList.indexWhere((dm) {
          final name = dm.tenDanhMuc.toLowerCase();
          final nameNoSpace = name.replaceAll(' ', '');
          final isDiDongKw = kwNoSpace.contains('didong') || kw.contains('di động') || kw.contains('mobile');
          
          return name.contains(kw) ||
                 nameNoSpace.contains(kwNoSpace) ||
                 (isDiDongKw && (name.contains('di động') || name.contains('di dong') || name.contains('mobile')));
        });
        
        // NẾU TÌM THẤY, CHỌN DANH MỤC ĐÓ VÀ TẢI KHÓA HỌC THEO DANH MỤC
        if (idx != -1) {
          setState(() {
            _selectedCategoryIndex = idx + 1; // +1 vì index 0 là "Tất cả"
          });
          _loadCoursesByCategory(_danhMucList[idx].maDanhMuc);
        }
      }
    } catch (e) {
      // XỬ LÝ LỖI KHI TẢI DỮ LIỆU
      setState(() {
        _errorMessage = 'Không thể tải dữ liệu. Vui lòng thử lại!';
        _isLoading = false;
      });
      print('Error loading data: $e');
    }
  }

  // PHƯƠNG THỨC TẢI KHÓA HỌC THEO DANH MỤC
  Future<void> _loadCoursesByCategory(String maDanhMuc) async {
    setState(() {
      _isLoadingCategory = true;
    });

    try {
      // GỌI API LẤY KHÓA HỌC THEO MÃ DANH MỤC
      final courses = await _repository.getKhoaHocTheoDanhMuc(maDanhMuc: maDanhMuc);
      
      setState(() {
        _filteredCourses = courses;
        _isLoadingCategory = false;
      });
    } catch (e) {
      // NẾU LỖI, THỬ LỌC THỦ CÔNG THEO TÊN DANH MỤC
      print('Error loading courses by category: $e');
      
      final categoryName = _danhMucList[_selectedCategoryIndex - 1].tenDanhMuc;
      final filtered = _allCourses.where((course) {
        return course.tenKhoaHoc.toLowerCase().contains(
              categoryName.toLowerCase().split(' ').first) || // Tìm theo từ đầu tiên
            course.moTa.toLowerCase().contains(
              categoryName.toLowerCase().split(' ').first);
      }).toList();
      
      setState(() {
        _filteredCourses = filtered;
        _isLoadingCategory = false;
      });
      
      // HIỂN THỊ THÔNG BÁO NẾU KHÔNG TÌM THẤY KHÓA HỌC
      if (filtered.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không tìm thấy khóa học cho danh mục "$categoryName"'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // PHƯƠNG THỨC LỌC KHÓA HỌC THEO DANH MỤC VÀ TỪ KHÓA TÌM KIẾM
  void _filterCourses() {
    if (_selectedCategoryIndex == 0) {
      // TRƯỜNG HỢP "TẤT CẢ" DANH MỤC
      List<KhoaHocModel> filtered = _allCourses;
      
      // LỌC THEO TỪ KHÓA TÌM KIẾM NẾU CÓ
      if (_searchQuery.isNotEmpty) {
        filtered = filtered.where((course) {
          return course.tenKhoaHoc.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 course.moTa.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 course.getTenNguoiTao().toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();
      }
      
      setState(() {
        _filteredCourses = filtered;
      });
    } else {
      // TRƯỜNG HỢP ĐÃ CHỌN DANH MỤC CỤ THỂ
      final selectedCategory = _danhMucList[_selectedCategoryIndex - 1];
      _loadCoursesByCategory(selectedCategory.maDanhMuc);
    }
  }

  // XỬ LÝ KHI NHẤN VÀO DANH MỤC
  void _onCategoryTap(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      _searchController.clear(); // Xóa tìm kiếm khi chuyển danh mục
      _searchQuery = '';
    });
    _filterCourses(); // Áp dụng bộ lọc mới
  }

  // XỬ LÝ KHI TÌM KIẾM (onChanged của TextField)
  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterCourses(); // Lọc lại danh sách khóa học
  }

  // XỬ LÝ KHI NHẤN VÀO KHÓA HỌC - ĐIỀU HƯỚNG ĐẾN CHI TIẾT
  void _onCourseTap(KhoaHocModel course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(khoaHoc: course),
      ),
    );
  }

  // WIDGET HIỂN THỊ CÁC CHIP DANH MỤC (dạng cuộn ngang)
  Widget _buildCategoryChips() {
    if (_danhMucList.isEmpty) {
      return Container(
        height: 50,
        alignment: Alignment.center,
        child: const Text(
          'Không có danh mục',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NHÃN "DANH MỤC:"
          Text(
            'Danh mục:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          
          // LISTVIEW CÁC CHIP DANH MỤC (CUỘN NGANG)
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(), // Hiệu ứng cuộn mượt
              itemCount: _danhMucList.length + 1, // +1 cho chip "Tất cả"
              itemBuilder: (context, index) {
                final isSelected = index == _selectedCategoryIndex;
                
                // CHIP "TẤT CẢ" (INDEX 0)
                if (index == 0) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: InputChip(
                      label: const Text(
                        'Tất cả',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFF6C63FF), // Màu khi được chọn
                      onSelected: (_) => _onCategoryTap(index),
                      backgroundColor: Colors.grey[100],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                }
                
                // CHIP CÁC DANH MỤC KHÁC
                final category = _danhMucList[index - 1];
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: InputChip(
                    label: SizedBox(
                      width: 80, // Giới hạn chiều rộng để tránh tràn
                      child: Text(
                        category.tenDanhMuc,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis, // Hiện "..." nếu quá dài
                        textAlign: TextAlign.center,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF6C63FF),
                    onSelected: (_) => _onCategoryTap(index),
                    backgroundColor: Colors.grey[100],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
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

  // WIDGET THANH TÌM KIẾM
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: _onSearch, // Gọi mỗi khi nhập
        decoration: InputDecoration(
          hintText: 'Tìm kiếm khóa học...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF6C63FF)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    _onSearch(''); // Xóa tìm kiếm
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey[50], // Màu nền nhạt
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none, // Không viền
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          hintStyle: const TextStyle(color: Colors.grey),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  // WIDGET HIỂN THỊ SỐ LƯỢNG KHÓA HỌC
  Widget _buildCourseCount() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // HIỂN THỊ SỐ LƯỢNG
          Text(
            '${_filteredCourses.length} khóa học',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          
          // HIỂN THỊ TÊN DANH MỤC ĐƯỢC CHỌN (NẾU KHÔNG PHẢI "TẤT CẢ")
          if (_selectedCategoryIndex > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _danhMucList[_selectedCategoryIndex - 1].tenDanhMuc,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6C63FF),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  // WIDGET LƯỚI HIỂN THỊ DANH SÁCH KHÓA HỌC (Grid 2 cột)
  Widget _buildCoursesGrid() {
    // TRẠNG THÁI ĐANG TẢI THEO DANH MỤC
    if (_isLoadingCategory) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF6C63FF),
            ),
            const SizedBox(height: 12),
            Text(
              'Đang tải khóa học...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // TRẠNG THÁI DANH SÁCH RỖNG
    if (_filteredCourses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ICON TRỐNG
            Icon(
              Icons.school_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            
            // THÔNG BÁO TÙY THEO TRẠNG THÁI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _searchQuery.isNotEmpty
                    ? 'Không tìm thấy khóa học "$_searchQuery"' // Tìm kiếm không có kết quả
                    : _selectedCategoryIndex > 0
                      ? 'Không có khóa học nào trong danh mục này' // Danh mục trống
                      : 'Không có khóa học nào', // Danh sách rỗng hoàn toàn
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            
            // NÚT "HIỂN THỊ TẤT CẢ" KHI CÓ TÌM KIẾM HOẶC ĐÃ CHỌN DANH MỤC
            if (_searchQuery.isNotEmpty || _selectedCategoryIndex > 0)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedCategoryIndex = 0; // Về "Tất cả"
                    _searchController.clear(); // Xóa tìm kiếm
                    _searchQuery = '';
                    _filteredCourses = _allCourses; // Hiển thị tất cả
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text('Hiển thị tất cả'),
              ),
          ],
        ),
      );
    }

    // HIỂN THỊ LƯỚI KHÓA HỌC (2 CỘT)
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 cột
        mainAxisSpacing: 6, // Khoảng cách dọc
        crossAxisSpacing: 6, // Khoảng cách ngang
        childAspectRatio: 0.72, // Tỉ lệ chiều rộng/chiều cao
      ),
      itemCount: _filteredCourses.length,
      itemBuilder: (context, index) {
        final course = _filteredCourses[index];
        return KhoaHocCard(
          khoaHoc: course,
          onTap: () => _onCourseTap(course),
          imageUrl: _getCourseImage(course), // Truyền ảnh đã xử lý
        );
      },
    );
  }

  // WIDGET LOADING KHI TẢI DỮ LIỆU CHÍNH
  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF6C63FF),
          ),
          SizedBox(height: 16),
          Text(
            'Đang tải dữ liệu...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET HIỂN THỊ LỖI
  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _errorMessage,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          // NÚT THỬ LẠI
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  // THANH ĐIỀU HƯỚNG DƯỚI CÙNG (BOTTOM NAVIGATION BAR)
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 1, // Tab "Khóa học" đang active
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF6C63FF), // Màu khi được chọn
      unselectedItemColor: Colors.grey[600],      // Màu khi không được chọn
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      onTap: (index) {
        if (index == 0) {
          Navigator.pop(context);
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

  // PHƯƠNG THỨC XÂY DỰNG GIAO DIỆN CHÍNH
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // HEADER CỦA MÀN HÌNH
            HeaderWidget(
              title: "Khóa Học",
              subtitle: "Khám phá và học tập với hàng ngàn khóa học chất lượng",
              showBackButton: true,
              onBackPressed: () => Navigator.pop(context), // Quay lại màn hình trước
              actions: [
                // NÚT TÌM KIẾM (ẨN/HIỆN THANH TÌM KIẾM)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showSearchBar = !_showSearchBar;
                    });
                    if (_showSearchBar) {
                      // Tự động focus vào ô tìm kiếm khi hiển thị
                      Future.delayed(const Duration(milliseconds: 50), () {
                        _searchFocusNode.requestFocus();
                      });
                    }
                  },
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                // NÚT THÔNG BÁO
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thông báo'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
            
            // THANH TÌM KIẾM (HIỆN/ẨN VỚI HIỆU ỨNG)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _showSearchBar ? _buildSearchBar() : const SizedBox.shrink(),
            ),
            
            // DANH MỤC (CHIPS)
            _buildCategoryChips(),
            
            // SỐ LƯỢNG KHÓA HỌC
            _buildCourseCount(),
            
            // DANH SÁCH KHÓA HỌC (GRID VIEW)
            Expanded(
              child: _isLoading
                  ? _buildLoading() // Loading chính
                  : _errorMessage.isNotEmpty
                      ? _buildError() // Lỗi
                      : _buildCoursesGrid(), // Danh sách khóa học
            ),
          ],
        ),
      ),
      
      // THANH ĐIỀU HƯỚNG DƯỚI CÙNG
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // DỌN DẸP TÀI NGUYÊN KHI WIDGET BỊ HỦY
  @override
  void dispose() {
    _searchController.dispose(); // Giải phóng controller
    _searchFocusNode.dispose();  // Giải phóng focus node
    super.dispose();
  }
}

// CUSTOM SEARCH DELEGATE (KHÔNG ĐƯỢC SỬ DỤNG TRONG CODE HIỆN TẠI)
// Lớp này có thể dùng cho tìm kiếm toàn màn hình (full-screen search)
class _CourseSearchDelegate extends SearchDelegate<String> {
  final List<KhoaHocModel> courses;
  final Function(KhoaHocModel) onCourseTap;

  _CourseSearchDelegate(this.courses, this.onCourseTap);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ''; // Xóa nội dung tìm kiếm
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, ''); // Đóng search
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(); // Kết quả tìm kiếm
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(); // Gợi ý khi đang nhập
  }

  // XÂY DỰNG KẾT QUẢ TÌM KIẾM
  Widget _buildSearchResults() {
    final results = query.isEmpty
        ? courses // Hiển thị tất cả nếu query rỗng
        : courses.where((course) {
            // Lọc theo tên, mô tả, hoặc người tạo
            return course.tenKhoaHoc.toLowerCase().contains(query.toLowerCase()) ||
                   course.moTa.toLowerCase().contains(query.toLowerCase()) ||
                   course.getTenNguoiTao().toLowerCase().contains(query.toLowerCase());
          }).toList();

    // TRẢ VỀ DANH SÁCH RỖNG NẾU KHÔNG TÌM THẤY
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy khóa học "$query"',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // HIỂN THỊ DANH SÁCH KẾT QUẢ DẠNG LIST
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final course = results[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.school, color: Color(0xFF6C63FF)),
            ),
            title: Text(
              course.tenKhoaHoc,
              style: const TextStyle(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  course.moTa.length > 60 
                      ? '${course.moTa.substring(0, 60)}...' // Cắt mô tả nếu quá dài
                      : course.moTa,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      course.danhGia, // Hiển thị đánh giá
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () {
              onCourseTap(course); // Xử lý khi nhấn vào khóa học
              close(context, course.tenKhoaHoc); // Đóng search và trả về tên khóa học
            },
          ),
        );
      },
    );
  }

  @override
  String get searchFieldLabel => 'Tìm kiếm khóa học...'; // Nhãn cho ô tìm kiếm
}
