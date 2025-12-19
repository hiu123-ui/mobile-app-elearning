// [file name]: main.dart
import 'package:flutter/material.dart';
import 'package:nhom_4_quan_ly_khoa_hoc/models/khoa_hoc_model.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/course_detail_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Learning',
      theme: ThemeData(
        primaryColor: const Color(0xFF6C63FF),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          accentColor: const Color(0xFF6C63FF),
        ),
        fontFamily: 'Roboto',
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/register': (context) => const RegisterScreen(),
        '/courses': (context) => const CoursesScreen(),
        '/course-detail': (context) {
          final course = ModalRoute.of(context)!.settings.arguments as KhoaHocModel;
          return CourseDetailScreen(khoaHoc: course);
        },
      },
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0,
          ),
          child: child!,
        );
      },
    );
  }
}