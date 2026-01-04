// [file name]: main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/course_detail_screen.dart';
import 'screens/blog_screen.dart';
import 'models/khoa_hoc_model.dart';
import 'screens/account_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'E-Learning App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const AuthWrapper(),
        routes: {
          '/home': (context) => HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/courses': (context) => const CoursesScreen(),
          '/course-detail': (context) {
            final course = ModalRoute.of(context)!.settings.arguments as KhoaHocModel;
            return CourseDetailScreen(khoaHoc: course);
          },
          '/account': (context) {
            final args = ModalRoute.of(context)!.settings.arguments;
            String? section;
            bool registrationSuccess = false;
            String? courseName;
            if (args is String?) {
              section = args;
            } else if (args is Map) {
              section = args['section'] as String?;
              registrationSuccess = (args['registered'] as bool?) ?? false;
              courseName = args['courseName'] as String?;
            }
            return AccountScreen(initialSection: section, registrationSuccess: registrationSuccess, registeredCourseName: courseName);
          },
          '/blog': (context) => const BlogScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// Widget kiểm tra trạng thái đăng nhập
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Hiển thị loading khi đang kiểm tra
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Kiểm tra đã đăng nhập chưa
    return authProvider.isLoggedIn ? HomeScreen() : const LoginScreen();
  }
}
