import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../screens/home_screen.dart';
import '../screens/register_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

// MÀN HÌNH ĐĂNG NHẬP - StatefulWidget để quản lý trạng thái nhập liệu và xử lý đăng nhập
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

// LỚP TRẠNG THÁI CỦA MÀN HÌNH ĐĂNG NHẬP
class _LoginScreenState extends State<LoginScreen> {
  // REPOSITORY VÀ CONTROLLERS CHO FORM
  final AuthRepository _authRepository = AuthRepository(); // Repository xử lý logic đăng nhập
  final TextEditingController _usernameController = TextEditingController(); // Controller cho tên đăng nhập
  final TextEditingController _passwordController = TextEditingController(); // Controller cho mật khẩu

  // BIẾN TRẠNG THÁI
  bool _isLoading = false;         // Trạng thái đang xử lý đăng nhập (hiển thị loading)
  bool _obscurePassword = true;    // Trạng thái ẩn/hiện mật khẩu (mặc định là ẩn)
  String _errorMessage = '';       // Thông báo lỗi nếu đăng nhập thất bại

  // PHƯƠNG THỨC XỬ LÝ ĐĂNG NHẬP
  Future<void> _handleLogin() async {
    // KIỂM TRA DỮ LIỆU ĐẦU VÀO
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập đầy đủ thông tin'; // Thông báo lỗi nếu thiếu thông tin
      });
      return; // Dừng xử lý nếu thiếu thông tin
    }

    // BẮT ĐẦU QUÁ TRÌNH ĐĂNG NHẬP
    setState(() {
      _isLoading = true;       // Bật trạng thái loading
      _errorMessage = '';      // Reset thông báo lỗi
    });

    try {
      // LẤY AUTH PROVIDER TỪ CONTEXT (listen: false vì không cần rebuild khi provider thay đổi)
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // GỌI PHƯƠNG THỨC LOGIN CỦA PROVIDER
      final ok = await authProvider.login(
        _usernameController.text.trim(),  // Tên đăng nhập (đã trim khoảng trắng)
        _passwordController.text.trim(),  // Mật khẩu (đã trim khoảng trắng)
      );
      
      // KIỂM TRA NẾU WIDGET ĐÃ BỊ UNMOUNT (TRÁNH LỖI SETSTATE)
      if (!mounted) return;
      
      if (ok) {
        // ĐĂNG NHẬP THÀNH CÔNG: ĐIỀU HƯỚNG ĐẾN TRANG CHỦ
        Navigator.pushReplacementNamed(context, '/home'); // Thay thế màn hình hiện tại bằng home
      } else {
        // ĐĂNG NHẬP THẤT BẠI: HIỂN THỊ THÔNG BÁO LỖI
        setState(() {
          // Lấy thông báo lỗi từ provider, xóa tiền tố "Exception: " nếu có
          _errorMessage = authProvider.errorMessage?.replaceAll('Exception: ', '') ?? 'Đăng nhập thất bại';
          _isLoading = false; // Tắt loading
        });
      }
    } catch (e) {
      // XỬ LÝ NGOẠI LỆ (LỖI KHÔNG XÁC ĐỊNH)
      print('Lỗi đăng nhập: $e'); // Log lỗi ra console
      setState(() {
        // Hiển thị thông báo lỗi, xóa tiền tố "Exception: " nếu có
        _errorMessage = 'Đăng nhập thất bại: ${e.toString().replaceAll('Exception: ', '')}';
        _isLoading = false; // Tắt loading
      });
    }
  }

  // PHƯƠNG THỨC XÂY DỰNG GIAO DIỆN CHÍNH
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Nền trắng
      body: SafeArea( // Đảm bảo nội dung không bị che bởi notch/status bar
        child: SingleChildScrollView( // Cho phép cuộn khi bàn phím hiện lên
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa theo chiều ngang
            children: [
              // PHẦN LOGO VÀ TIÊU ĐỀ
              const SizedBox(height: 60), // Khoảng cách từ trên xuống
              const Text(
                'E-LEARNING', // Tên ứng dụng
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C63FF), // Màu tím chủ đạo
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Đăng nhập để tiếp tục học tập', // Mô tả
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600], // Màu xám
                ),
              ),
              const SizedBox(height: 80),

              // FORM ĐĂNG NHẬP (CARD)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white, // Nền trắng
                  borderRadius: BorderRadius.circular(20), // Bo góc
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1), // Đổ bóng nhẹ
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // TRƯỜNG NHẬP TÊN ĐĂNG NHẬP
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Tên đăng nhập', // Nhãn
                        labelStyle: TextStyle(color: Colors.grey[600]), // Màu nhãn
                        prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF6C63FF)), // Icon trước
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), // Bo góc viền
                          borderSide: BorderSide(color: Colors.grey[300]!), // Màu viền mặc định
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2), // Viền khi focus
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16), // Padding nội dung
                      ),
                    ),
                    const SizedBox(height: 20), // Khoảng cách giữa các trường

                    // TRƯỜNG NHẬP MẬT KHẨU
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword, // Ẩn mật khẩu (dấu *)
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu', // Nhãn
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6C63FF)), // Icon ổ khóa
                        suffixIcon: IconButton( // Icon hiện/ẩn mật khẩu
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility, // Đổi icon theo trạng thái
                            color: Colors.grey[500],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword; // Đảo trạng thái ẩn/hiện
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                    ),

                    // HIỂN THỊ THÔNG BÁO LỖI NẾU CÓ
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Colors.red, // Màu đỏ cho thông báo lỗi
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 30), // Khoảng cách trước nút đăng nhập

                    // NÚT ĐĂNG NHẬP
                    SizedBox(
                      width: double.infinity, // Chiếm toàn bộ chiều ngang
                      height: 54, // Chiều cao cố định
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin, // Disable khi đang loading
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF), // Màu nền tím
                          foregroundColor: Colors.white, // Màu chữ trắng
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // Bo góc nút
                          ),
                          elevation: 0, // Không đổ bóng
                        ),
                        child: _isLoading
                            ? const SizedBox( // HIỂN THỊ LOADING KHI ĐANG XỬ LÝ
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white, // Màu trắng cho indicator
                                  strokeWidth: 2, // Độ dày
                                ),
                              )
                            : const Text( // HIỂN THỊ CHỮ "ĐĂNG NHẬP" KHI KHÔNG LOADING
                                'ĐĂNG NHẬP',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 30), // Khoảng cách sau nút đăng nhập

                    // LIÊN KẾT ĐẾN MÀN HÌNH ĐĂNG KÝ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Căn giữa
                      children: [
                        Text(
                          'Chưa có tài khoản? ', // Văn bản thông thường
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        GestureDetector( // Widget có thể nhấn
                          onTap: () {
                            // ĐIỀU HƯỚNG ĐẾN MÀN HÌNH ĐĂNG KÝ
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterScreen()),
                            );
                          },
                          child: const Text(
                            'Đăng ký ngay', // Văn bản có thể nhấn
                            style: TextStyle(
                              color: Color(0xFF6C63FF), // Màu tím để phân biệt
                              fontWeight: FontWeight.w600, // Đậm hơn
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40), // Khoảng cách dưới cùng
            ],
          ),
        ),
      ),
    );
  }

  // DỌN DẸP TÀI NGUYÊN KHI WIDGET BỊ HỦY
  @override
  void dispose() {
    _usernameController.dispose(); // Giải phóng bộ nhớ của controller
    _passwordController.dispose();
    super.dispose();
  }
}