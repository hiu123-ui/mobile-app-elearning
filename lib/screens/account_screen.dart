import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/user_profile_widget.dart';
import '../widgets/header_widget.dart';
import '../repositories/khoa_hoc_repository.dart';
import '../models/khoa_hoc_model.dart';
import '../widgets/khoa_hoc_card.dart';
import '../services/api_service.dart';

class AccountScreen extends StatefulWidget {
  final String? initialSection;
  final bool registrationSuccess;
  final String? registeredCourseName;
  const AccountScreen({super.key, this.initialSection, this.registrationSuccess = false, this.registeredCourseName});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

enum AccountSection { none, personalInfo, updateInfo, myCourses }

class _AccountScreenState extends State<AccountScreen> {
  AccountSection _selected = AccountSection.none;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _groupController = TextEditingController();
  final _passwordController = TextEditingController();
  final KhoaHocRepository _repo = KhoaHocRepository();
  bool _hasShownSuccessSnack = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.hoTen;
      _emailController.text = user.email;
      _phoneController.text = user.soDT;
      _usernameController.text = user.taiKhoan;
      _groupController.text = user.maNhom;
    }
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
        _selected = AccountSection.none;
    }
    if (widget.registrationSuccess && _selected == AccountSection.myCourses) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_hasShownSuccessSnack) {
          _hasShownSuccessSnack = true;
          final courseName = widget.registeredCourseName ?? 'Khóa học';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đăng ký thành công: "$courseName"'),
              backgroundColor: Colors.green,
            ),
          );
        }
      });
    }
  }

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

  Widget _buildMenu(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.person_outline, color: Color(0xFF6C63FF)),
            title: const Text('Thông tin cá nhân'),
            subtitle: const Text('Xem hồ sơ của bạn'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => setState(() => _selected = AccountSection.personalInfo),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.edit_outlined, color: Color(0xFF6C63FF)),
            title: const Text('Cập nhật thông tin'),
            subtitle: const Text('Chỉnh sửa hồ sơ'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => setState(() => _selected = AccountSection.updateInfo),
          ),
        ),
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

  Widget _buildPersonalInfo(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (auth.user == null) {
      return Center(child: Text('Chưa đăng nhập', style: TextStyle(color: Colors.grey[600])));
    }
    final u = auth.user!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const UserProfileWidget(),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.badge_outlined, color: Color(0xFF6C63FF)),
                  title: const Text('Họ tên'),
                  subtitle: Text(u.hoTen),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.person_outline, color: Color(0xFF6C63FF)),
                  title: const Text('Tên đăng nhập'),
                  subtitle: Text(u.taiKhoan),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email_outlined, color: Color(0xFF6C63FF)),
                  title: const Text('Email'),
                  subtitle: Text(u.email),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone_outlined, color: Color(0xFF6C63FF)),
                  title: const Text('Điện thoại'),
                  subtitle: Text(u.soDT),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFE6F4EA), borderRadius: BorderRadius.circular(20)),
                    child: const Text('Đã cập nhật', style: TextStyle(color: Color(0xFF2E7D32), fontSize: 12)),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.group_outlined, color: Color(0xFF6C63FF)),
                  title: const Text('Mã nhóm'),
                  subtitle: Text(u.maNhom),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
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

  Widget _buildUpdateInfo(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          TextField(
            controller: _usernameController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Tên đăng nhập',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Mật khẩu mới',
              hintText: 'Để trống nếu không đổi mật khẩu',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Họ và tên',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Số điện thoại',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _groupController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Mã nhóm',
              prefixIcon: Icon(Icons.group_outlined),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final auth = Provider.of<AuthProvider>(context, listen: false);
                    if (auth.user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng đăng nhập')),
                      );
                      return;
                    }
                    final name = _nameController.text.trim();
                    final email = _emailController.text.trim();
                    final phone = _phoneController.text.trim();
                    final newPwd = _passwordController.text.trim();
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
                      final ok = await auth.updateProfile(
                        hoTen: name,
                        email: email,
                        soDT: phone,
                        matKhau: newPwd.isNotEmpty ? newPwd : null,
                      );
                      if (!mounted) return;
                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cập nhật thành công'), backgroundColor: Colors.green),
                        );
                        setState(() {
                          _passwordController.clear();
                          _selected = AccountSection.personalInfo;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(auth.errorMessage ?? 'Cập nhật thất bại')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Lưu thay đổi'),
                ),
              ),
              const SizedBox(width: 12),
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

  Widget _buildMyCourses(BuildContext context) {
    return FutureBuilder<List<KhoaHocModel>>(
      future: ApiService.layKhoaHocGhiDanhCuaTaiKhoan(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi tải khóa học', style: TextStyle(color: Colors.grey[600])));
        }
        final courses = snapshot.data ?? [];
        if (courses.isEmpty) {
          return Center(child: Text('Chưa có khóa học', style: TextStyle(color: Colors.grey[600])));
        }
        return Column(
          children: [
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
                      registered: true,
                      primaryLabel: 'Đã đăng ký',
                      onTap: () {
                        Navigator.pushNamed(context, '/course-detail', arguments: c);
                      },
                      secondaryLabel: 'Xóa',
                      onSecondary: () async {
                        final auth = Provider.of<AuthProvider>(context, listen: false);
                        final user = auth.user;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Vui lòng đăng nhập')),
                          );
                          return;
                        }
                        try {
                          await ApiService.huyDangKyKhoaHoc(
                            maKhoaHoc: c.maKhoaHoc,
                            taiKhoan: user.taiKhoan,
                          );
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã hủy đăng ký'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          setState(() {});
                        } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
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
              showBackButton: _selected != AccountSection.none,
              onBackPressed: () => setState(() => _selected = AccountSection.none),
            ),
            Expanded(
              child: authProvider.user == null
                  ? Center(
                      child: Text(
                        'Chưa đăng nhập',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    )
                  : _selected == AccountSection.none
                      ? _buildMenu(context)
                      : _selected == AccountSection.personalInfo
                          ? _buildPersonalInfo(context)
                          : _selected == AccountSection.updateInfo
                              ? _buildUpdateInfo(context)
                              : _buildMyCourses(context),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 4,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF6C63FF),
      unselectedItemColor: Colors.grey[600],
      onTap: (index) {
        if (index == 1) {
          Navigator.pushNamed(context, '/courses');
        } else if (index == 4) {
          // Đã ở trang Tài khoản, không cần điều hướng
        } else if (index == 0) {
          Navigator.pushNamed(context, '/');
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
}
