// [file name]: screens/courses_screen.dart
import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../models/danh_muc_model.dart';
import '../models/khoa_hoc_model.dart';
import '../repositories/khoa_hoc_repository.dart';
import '../widgets/khoa_hoc_card.dart';
import './course_detail_screen.dart';

class CoursesScreen extends StatefulWidget {
  final String? initialCategoryName;
  const CoursesScreen({super.key, this.initialCategoryName});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final KhoaHocRepository _repository = KhoaHocRepository();

  // State
  List<DanhMucModel> _danhMucList = [];
  List<KhoaHocModel> _allCourses = [];
  List<KhoaHocModel> _filteredCourses = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _selectedCategoryIndex = 0; // 0 = Tất cả
  bool _isLoadingCategory = false;
  bool _showSearchBar = false;

  // Tìm kiếm
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode();
  final Map<String, String> _imageByCategory = {
    'frontend': 'https://tse1.mm.bing.net/th/id/OIP.KnzMtsMOM8yG0Fx8pNLBYQHaEf?pid=Api&P=0&h=220',
    'backend': 'https://canhme.com/wp-content/uploads/2018/09/Nodejs.png',
    'fullstack': 'https://tse4.mm.bing.net/th/id/OIP.tx5zOJG8j8o3Ke6-UTK3TAHaDf?pid=Api&P=0&h=220',
    'didong': 'https://tse2.mm.bing.net/th/id/OIP.UzgaU4gKG_GkXhlHigItPQHaEK?pid=Api&P=0&h=220',
  };

  String? _getCourseImage(KhoaHocModel c) {
    String? url;
    if (_selectedCategoryIndex > 0 && _selectedCategoryIndex - 1 < _danhMucList.length) {
      final cat = _danhMucList[_selectedCategoryIndex - 1].tenDanhMuc.toLowerCase();
      final catNorm = cat.replaceAll(' ', '');
      if (catNorm.contains('frontend')) url = _imageByCategory['frontend'];
      if (catNorm.contains('backend')) url = _imageByCategory['backend'];
      if (catNorm.contains('fullstack')) url = _imageByCategory['fullstack'];
      if (cat.contains('di động') || cat.contains('di dong') || catNorm.contains('didong') || cat.contains('mobile')) {
        url = _imageByCategory['didong'];
      }
    }
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
    return url ?? (c.hinhAnh.isNotEmpty ? c.hinhAnh : null);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load danh mục
      final categories = await _repository.getDanhSachDanhMuc();
      
      // Load tất cả khóa học
      final courses = await _repository.getDanhSachKhoaHoc();
      
      setState(() {
        _danhMucList = categories;
        _allCourses = courses;
        _filteredCourses = courses;
        _isLoading = false;
      });
      // Chọn danh mục ban đầu nếu được truyền từ màn hình trước
      if (widget.initialCategoryName != null && widget.initialCategoryName!.trim().isNotEmpty) {
        final kw = widget.initialCategoryName!.toLowerCase();
        final kwNoSpace = kw.replaceAll(' ', '');
        int idx = _danhMucList.indexWhere((dm) {
          final name = dm.tenDanhMuc.toLowerCase();
          final nameNoSpace = name.replaceAll(' ', '');
          final isDiDongKw = kwNoSpace.contains('didong') || kw.contains('di động') || kw.contains('mobile');
          return name.contains(kw) ||
                 nameNoSpace.contains(kwNoSpace) ||
                 (isDiDongKw && (name.contains('di động') || name.contains('di dong') || name.contains('mobile')));
        });
        if (idx != -1) {
          setState(() {
            _selectedCategoryIndex = idx + 1;
          });
          _loadCoursesByCategory(_danhMucList[idx].maDanhMuc);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải dữ liệu. Vui lòng thử lại!';
        _isLoading = false;
      });
      print('Error loading data: $e');
    }
  }

  Future<void> _loadCoursesByCategory(String maDanhMuc) async {
    setState(() {
      _isLoadingCategory = true;
    });

    try {
      final courses = await _repository.getKhoaHocTheoDanhMuc(maDanhMuc: maDanhMuc);
      
      setState(() {
        _filteredCourses = courses;
        _isLoadingCategory = false;
      });
    } catch (e) {
      print('Error loading courses by category: $e');
      // Nếu không tìm thấy theo danh mục, lọc theo tên danh mục
      final categoryName = _danhMucList[_selectedCategoryIndex - 1].tenDanhMuc;
      final filtered = _allCourses.where((course) {
        return course.tenKhoaHoc.toLowerCase().contains(
              categoryName.toLowerCase().split(' ').first) ||
            course.moTa.toLowerCase().contains(
              categoryName.toLowerCase().split(' ').first);
      }).toList();
      
      setState(() {
        _filteredCourses = filtered;
        _isLoadingCategory = false;
      });
      
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

  void _filterCourses() {
    if (_selectedCategoryIndex == 0) {
      // Hiển thị tất cả khóa học
      List<KhoaHocModel> filtered = _allCourses;
      
      // Lọc theo tìm kiếm nếu có
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
      // Lọc theo danh mục đã chọn
      final selectedCategory = _danhMucList[_selectedCategoryIndex - 1];
      _loadCoursesByCategory(selectedCategory.maDanhMuc);
    }
  }

  void _onCategoryTap(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      _searchController.clear();
      _searchQuery = '';
    });
    _filterCourses();
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterCourses();
  }

  void _onCourseTap(KhoaHocModel course) {
    // Điều hướng đến trang chi tiết khóa học
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(khoaHoc: course),
      ),
    );
  }

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
          Text(
            'Danh mục:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _danhMucList.length + 1,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedCategoryIndex;
                
                if (index == 0) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: InputChip(
                      label: const Text(
                        'Tất cả',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFF6C63FF),
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
                
                final category = _danhMucList[index - 1];
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: InputChip(
                    label: SizedBox(
                      width: 80, // Giới hạn chiều rộng để tránh overflow
                      child: Text(
                        category.tenDanhMuc,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: _onSearch,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm khóa học...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF6C63FF)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    _onSearch('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          hintStyle: const TextStyle(color: Colors.grey),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildCourseCount() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_filteredCourses.length} khóa học',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
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

  Widget _buildCoursesGrid() {
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

    if (_filteredCourses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _searchQuery.isNotEmpty
                    ? 'Không tìm thấy khóa học "$_searchQuery"'
                    : _selectedCategoryIndex > 0
                      ? 'Không có khóa học nào trong danh mục này'
                      : 'Không có khóa học nào',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            if (_searchQuery.isNotEmpty || _selectedCategoryIndex > 0)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedCategoryIndex = 0;
                    _searchController.clear();
                    _searchQuery = '';
                    _filteredCourses = _allCourses;
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

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 0.72,
      ),
      itemCount: _filteredCourses.length,
      itemBuilder: (context, index) {
        final course = _filteredCourses[index];
        return KhoaHocCard(
          khoaHoc: course,
          onTap: () => _onCourseTap(course),
          imageUrl: _getCourseImage(course),
        );
      },
    );
  }

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

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 1,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF6C63FF),
      unselectedItemColor: Colors.grey[600],
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      onTap: (index) {
        if (index == 0) {
          Navigator.pop(context);
        } else if (index == 2) {
          // TODO: Điều hướng đến trang danh mục
        } else if (index == 3) {
          // TODO: Điều hướng đến blog
        } else if (index == 4) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            HeaderWidget(
              title: "Khóa Học",
              subtitle: "Khám phá và học tập với hàng ngàn khóa học chất lượng",
              showBackButton: true,
              onBackPressed: () => Navigator.pop(context),
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showSearchBar = !_showSearchBar;
                    });
                    if (_showSearchBar) {
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _showSearchBar ? _buildSearchBar() : const SizedBox.shrink(),
            ),
            
            // Danh mục
            _buildCategoryChips(),
            
            // Số lượng khóa học
            _buildCourseCount(),
            
            // Danh sách khóa học
            Expanded(
              child: _isLoading
                  ? _buildLoading()
                  : _errorMessage.isNotEmpty
                      ? _buildError()
                      : _buildCoursesGrid(),
            ),
          ],
        ),
      ),
      
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}

// Custom Search Delegate
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
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = query.isEmpty
        ? courses
        : courses.where((course) {
            return course.tenKhoaHoc.toLowerCase().contains(query.toLowerCase()) ||
                   course.moTa.toLowerCase().contains(query.toLowerCase()) ||
                   course.getTenNguoiTao().toLowerCase().contains(query.toLowerCase());
          }).toList();

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
                      ? '${course.moTa.substring(0, 60)}...' 
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
                      course.danhGia,
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
              onCourseTap(course);
              close(context, course.tenKhoaHoc);
            },
          ),
        );
      },
    );
  }

  @override
  String get searchFieldLabel => 'Tìm kiếm khóa học...';
}
