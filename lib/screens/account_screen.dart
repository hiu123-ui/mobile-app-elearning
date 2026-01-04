import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/user_profile_widget.dart';
import '../widgets/header_widget.dart';
import '../repositories/khoa_hoc_repository.dart';
import '../models/khoa_hoc_model.dart';
import '../widgets/khoa_hoc_card.dart';
import '../services/api_service.dart';

// MÀN HÌNH TÀI KHOẢN - StatefulWidget để quản lý các trạng thái và thông tin người dùng
class AccountScreen extends StatefulWidget {
  final String? initialSection;              // Phần được mở mặc định khi vào màn hình
  final bool registrationSuccess;            // Trạng thái đăng ký thành công từ màn hình khác
  final String? registeredCourseName;        // Tên khóa học đã đăng ký (nếu có)
  
  const AccountScreen({
    super.key, 
    this.initialSection, 
    this.registrationSuccess = false, 
    this.registeredCourseName
  });

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

// ENUM ĐỊNH NGHĨA CÁC PHẦN (SECTION) CỦA MÀN HÌNH TÀI KHOẢN
enum AccountSection { none, personalInfo, updateInfo, myCourses }

// LỚP TRẠNG THÁI CỦA MÀN HÌNH TÀI KHOẢN
class _AccountScreenState extends State<AccountScreen> {
  // BIẾN TRẠNG THÁI
  AccountSection _selected = AccountSection.none;  // Phần đang được chọn hiển thị
  
  // CONTROLLERS CHO CÁC TRƯỜNG NHẬP LIỆU
  final _nameController = TextEditingController();      // Controller cho họ tên
  final _emailController = TextEditingController();     // Controller cho email
  final _phoneController = TextEditingController();     // Controller cho số điện thoại
  final _usernameController = TextEditingController();  // Controller cho tên đăng nhập
  final _groupController = TextEditingController();     // Controller cho mã nhóm
  final _passwordController = TextEditingController();  // Controller cho mật khẩu mới

  bool _hasShownSuccessSnack = false;  // Cờ kiểm tra đã hiển thị thông báo thành công chưa

  // KHỞI TẠO TRẠNG THÁI - GỌI KHI WIDGET ĐƯỢC TẠO
  @override
  void initState() {
    super.initState();
    
    // LẤY THÔNG TIN NGƯỜI DÙNG TỪ AUTH PROVIDER VÀ GÁN VÀO CÁC CONTROLLER
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.hoTen;
      _emailController.text = user.email;
      _phoneController.text = user.soDT;
      _usernameController.text = user.taiKhoan;
      _groupController.text = user.maNhom;
    }
    
    // XỬ LÝ PHẦN MỞ MẶC ĐỊNH TỪ THAM SỐ initialSection
    switch (widget.initialSection) {
      case 'personalInfo':
        _selected = AccountSection.personalInfo;
        break;
      case 'updateInfo':
        _selected = AccountSection.updateInfo;
        break;
      case 'myCourses':
        _selected = AccountSection.myCourses;
        break;
      default:
        _selected = AccountSection.none;  // Mặc định: menu chính
    }
    
    // HIỂN THỊ THÔNG BÁO ĐĂNG KÝ THÀNH CÔNG NẾU CÓ
    if (widget.registrationSuccess && _selected == AccountSection.myCourses) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_hasShownSuccessSnack) {
          _hasShownSuccessSnack = true;  // Đánh dấu đã hiển thị
          final courseName = widget.registeredCourseName ?? 'Khóa học';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đăng ký thành công: "$courseName"'),
              backgroundColor: Colors.green,  // Màu xanh cho thông báo thành công
            ),
          );
        }
      });
    }
  }

  // DỌN DẸP TÀI NGUYÊN KHI WIDGET BỊ HỦY
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _groupController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // WIDGET HIỂN THỊ MENU CHÍNH CỦA TÀI KHOẢN
  Widget _buildMenu(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // THẺ THÔNG TIN CÁ NHÂN
        Card(
          child: ListTile(
            leading: const Icon(Icons.person_outline, color: Color(0xFF6C63FF)),
            title: const Text('Thông tin cá nhân'),
            subtitle: const Text('Xem hồ sơ của bạn'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => setState(() => _selected = AccountSection.personalInfo),
          ),
        ),
        
        // THẺ CẬP NHẬT THÔNG TIN
        Card(
          child: ListTile(
            leading: const Icon(Icons.edit_outlined, color: Color(0xFF6C63FF)),
            title: const Text('Cập nhật thông tin'),
            subtitle: const Text('Chỉnh sửa hồ sơ'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => setState(() => _selected = AccountSection.updateInfo),
          ),
        ),
        
        // THẺ KHÓA HỌC CỦA TÔI
        Card(
          child: ListTile(
            leading: const Icon(Icons.school_outlined, color: Color(0xFF6C63FF)),
            title: const Text('Khóa học của tôi'),
            subtitle: const Text('Danh sách khóa học đã đăng ký'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => setState(() => _selected = AccountSection.myCourses),
          ),
        ),
      ],
    );
  }

  // WIDGET HIỂN THỊ THÔNG TIN CÁ NHÂN CHI TIẾT
  Widget _buildPersonalInfo(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    // KIỂM TRA NẾU CHƯA ĐĂNG NHẬP
    if (auth.user == null) {
      return Center(
        child: Text('Chưa đăng nhập', style: TextStyle(color: Colors.grey[600]))
      );
    }
    
    final u = auth.user!;  // Lấy thông tin người dùng
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, // Ẩn bàn phím khi cuộn
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // WIDGET HIỂN THỊ HỒ SƠ NGƯỜI DÙNG (AVATAR, TÊN)
          const UserProfileWidget(),
          const SizedBox(height: 16),
          
          // CARD HIỂN THỊ THÔNG TIN CHI TIẾT
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05), 
                  blurRadius: 8, 
                  offset: const Offset(0, 4)
                ),
              ],
            ),
            child: Column(
              children: [
                // HỌ TÊN
                ListTile(
                  leading: const Icon(Icons.badge_outlined, color: Color(0xFF6C63FF)),
                  title: const Text('Họ tên'),
                  subtitle: Text(u.hoTen),
                ),
                const Divider(height: 1),
                
                // TÊN ĐĂNG NHẬP
                ListTile(
                  leading: const Icon(Icons.person_outline, color: Color(0xFF6C63FF)),
                  title: const Text('Tên đăng nhập'),
                  subtitle: Text(u.taiKhoan),
                ),
                const Divider(height: 1),
                
                // EMAIL
                ListTile(
                  leading: const Icon(Icons.email_outlined, color: Color(0xFF6C63FF)),
                  title: const Text('Email'),
                  subtitle: Text(u.email),
                ),
                const Divider(height: 1),
                
                // SỐ ĐIỆN THOẠI (CÓ BADGE "ĐÃ CẬP NHẬT")
                ListTile(
                  leading: const Icon(Icons.phone_outlined, color: Color(0xFF6C63FF)),
                  title: const Text('Điện thoại'),
                  subtitle: Text(u.soDT),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F4EA), 
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: const Text(
                      'Đã cập nhật', 
                      style: TextStyle(color: Color(0xFF2E7D32), fontSize: 12)
                    ),
                  ),
                ),
                const Divider(height: 1),
                
                // MÃ NHÓM
                ListTile(
                  leading: const Icon(Icons.group_outlined, color: Color(0xFF6C63FF)),
                  title: const Text('Mã nhóm'),
                  subtitle: Text(u.maNhom),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // NÚT QUAY LẠI
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => setState(() => _selected = AccountSection.none),
              child: const Text('Quay lại'),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET HIỂN THỊ FORM CẬP NHẬT THÔNG TIN
  Widget _buildUpdateInfo(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom), // Padding tính cả bàn phím
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          
          // TRƯỜNG TÊN ĐĂNG NHẬP (CHỈ ĐỌC)
          TextField(
            controller: _usernameController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Tên đăng nhập',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          
          // TRƯỜNG MẬT KHẨU MỚI (CÓ THỂ ĐỂ TRỐNG)
          TextField(
            controller: _passwordController,
            obscureText: true, // Ẩn mật khẩu
            decoration: const InputDecoration(
              labelText: 'Mật khẩu mới',
              hintText: 'Để trống nếu không đổi mật khẩu',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 12),
          
          // TRƯỜNG HỌ TÊN
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Họ và tên',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 12),
          
          // TRƯỜNG EMAIL
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 12),
          
          // TRƯỜNG SỐ ĐIỆN THOẠI
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Số điện thoại',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 12),
          
          // TRƯỜNG MÃ NHÓM (CHỈ ĐỌC)
          TextField(
            controller: _groupController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Mã nhóm',
              prefixIcon: Icon(Icons.group_outlined),
            ),
          ),
          const SizedBox(height: 20),
          
          // HAI NÚT HÀNH ĐỘNG: LƯU THAY ĐỔI VÀ QUAY LẠI
          Row(
            children: [
              // NÚT LƯU THAY ĐỔI
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final auth = Provider.of<AuthProvider>(context, listen: false);
                    
                    // KIỂM TRA ĐĂNG NHẬP
                    if (auth.user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng đăng nhập')),
                      );
                      return;
                    }
                    
                    // LẤY DỮ LIỆU TỪ CÁC TRƯỜNG
                    final name = _nameController.text.trim();
                    final email = _emailController.text.trim();
                    final phone = _phoneController.text.trim();
                    final newPwd = _passwordController.text.trim();
                    
                    // KIỂM TRA VALIDATION
                    if (name.isEmpty || email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng nhập đủ họ tên và email')),
                      );
                      return;
                    }
                    
                    if (!email.contains('@') || !email.contains('.')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Email không hợp lệ')),
                      );
                      return;
                    }
                    
                    if (newPwd.isNotEmpty && newPwd.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mật khẩu mới tối thiểu 6 ký tự')),
                      );
                      return;
                    }
                    
                    try {
                      // GỌI PHƯƠNG THỨC CẬP NHẬT PROFILE
                      final ok = await auth.updateProfile(
                        hoTen: name,
                        email: email,
                        soDT: phone,
                        matKhau: newPwd.isNotEmpty ? newPwd : null, // Chỉ gửi nếu có mật khẩu mới
                      );
                      
                      if (!mounted) return;
                      
                      if (ok) {
                        // THÀNH CÔNG: HIỂN THỊ THÔNG BÁO VÀ CHUYỂN VỀ MÀN HÌNH THÔNG TIN
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cập nhật thành công'), 
                            backgroundColor: Colors.green
                          ),
                        );
                        setState(() {
                          _passwordController.clear(); // Xóa mật khẩu
                          _selected = AccountSection.personalInfo; // Về màn hình thông tin
                        });
                      } else {
                        // THẤT BẠI: HIỂN THỊ LỖI
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(auth.errorMessage ?? 'Cập nhật thất bại')
                          ),
                        );
                      }
                    } catch (e) {
                      // XỬ LÝ LỖI NGOẠI LỆ
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF), // Màu nền tím
                    foregroundColor: Colors.white,           // Màu chữ trắng
                  ),
                  child: const Text('Lưu thay đổi'),
                ),
              ),
              const SizedBox(width: 12),
              
              // NÚT QUAY LẠI
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _selected = AccountSection.none),
                  child: const Text('Quay lại'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // WIDGET HIỂN THỊ DANH SÁCH KHÓA HỌC ĐÃ ĐĂNG KÝ
  Widget _buildMyCourses(BuildContext context) {
    return FutureBuilder<List<KhoaHocModel>>(
      future: ApiService.layKhoaHocGhiDanhCuaTaiKhoan(), // Gọi API lấy khóa học đã đăng ký
      builder: (context, snapshot) {
        // TRẠNG THÁI ĐANG TẢI
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // TRẠNG THÁI LỖI
        if (snapshot.hasError) {
          return Center(
            child: Text('Lỗi tải khóa học', style: TextStyle(color: Colors.grey[600]))
          );
        }
        
        // LẤY DỮ LIỆU
        final courses = snapshot.data ?? [];
        
        // TRẠNG THÁI DANH SÁCH RỖNG
        if (courses.isEmpty) {
          return Center(
            child: Text('Chưa có khóa học', style: TextStyle(color: Colors.grey[600]))
          );
        }
        
        // HIỂN THỊ DANH SÁCH KHÓA HỌC
        return Column(
          children: [
            // DANH SÁCH KHÓA HỌC DẠNG LIST
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final c = courses[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: index < courses.length - 1 ? 12 : 0),
                    child: KhoaHocCard(
                      khoaHoc: c,
                      registered: true, // Đánh dấu đã đăng ký
                      primaryLabel: 'Đã đăng ký', // Nhãn chính
                      onTap: () {
                        // ĐIỀU HƯỚNG ĐẾN CHI TIẾT KHÓA HỌC
                        Navigator.pushNamed(context, '/course-detail', arguments: c);
                      },
                      secondaryLabel: 'Xóa', // Nhãn phụ
                      onSecondary: () async {
                        // XỬ LÝ HỦY ĐĂNG KÝ
                        final auth = Provider.of<AuthProvider>(context, listen: false);
                        final user = auth.user;
                        
                        // KIỂM TRA ĐĂNG NHẬP
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Vui lòng đăng nhập')),
                          );
                          return;
                        }
                        
                        try {
                          // GỌI API HỦY ĐĂNG KÝ
                          await ApiService.huyDangKyKhoaHoc(
                            maKhoaHoc: c.maKhoaHoc,
                            taiKhoan: user.taiKhoan,
                          );
                          
                          if (!mounted) return;
                          
                          // HIỂN THỊ THÔNG BÁO THÀNH CÔNG
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã hủy đăng ký'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          
                          // CẬP NHẬT LẠI GIAO DIỆN
                          setState(() {});
                        } catch (e) {
                          // XỬ LÝ LỖI
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Hủy đăng ký thất bại: $e')),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            
            // NÚT QUAY LẠI Ở DƯỚI CÙNG
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => setState(() => _selected = AccountSection.none),
                  child: const Text('Quay lại'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // PHƯƠNG THỨC XÂY DỰNG GIAO DIỆN CHÍNH
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: true, // Điều chỉnh kích thước để tránh bàn phím
      body: SafeArea(
        child: Column(
          children: [
            // HEADER VỚI TIÊU ĐỀ THAY ĐỔI THEO SECTION
            HeaderWidget(
              title: _selected == AccountSection.personalInfo
                  ? 'Thông tin cá nhân'
                  : _selected == AccountSection.updateInfo
                      ? 'Cập nhật thông tin'
                      : _selected == AccountSection.myCourses
                          ? 'Khóa học của tôi'
                          : 'Tài khoản',
              subtitle: _selected == AccountSection.personalInfo
                  ? 'Xem hồ sơ của bạn'
                  : _selected == AccountSection.updateInfo
                      ? 'Chỉnh sửa hồ sơ'
                      : _selected == AccountSection.myCourses
                          ? 'Danh sách khóa học đã đăng ký'
                          : 'Chọn chức năng',
              showBackButton: _selected != AccountSection.none, // Hiện nút back khi không ở menu chính
              onBackPressed: () => setState(() => _selected = AccountSection.none),
            ),
            
            // NỘI DUNG CHÍNH, THAY ĐỔI THEO SECTION ĐƯỢC CHỌN
            Expanded(
              child: authProvider.user == null
                  ? Center( // NẾU CHƯA ĐĂNG NHẬP
                      child: Text(
                        'Chưa đăng nhập',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    )
                  : _selected == AccountSection.none
                      ? _buildMenu(context) // MENU CHÍNH
                      : _selected == AccountSection.personalInfo
                          ? _buildPersonalInfo(context) // THÔNG TIN CÁ NHÂN
                          : _selected == AccountSection.updateInfo
                              ? _buildUpdateInfo(context) // CẬP NHẬT THÔNG TIN
                              : _buildMyCourses(context), // KHÓA HỌC CỦA TÔI
            ),
          ],
        ),
      ),
      
      // THANH ĐIỀU HƯỚNG DƯỚI CÙNG
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // WIDGET THANH ĐIỀU HƯỚNG DƯỚI CÙNG
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 3, // Tab "Tài khoản" đang active
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF6C63FF), // Màu khi được chọn
      unselectedItemColor: Colors.grey[600],      // Màu khi không được chọn
      onTap: (index) {
        if (index == 1) {
          Navigator.pushNamed(context, '/courses');
        } else if (index == 3) {
          // Đã ở trang Tài khoản
        } else if (index == 0) {
          Navigator.pushNamed(context, '/');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/blog');
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
}
