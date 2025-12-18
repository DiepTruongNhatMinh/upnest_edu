import 'package:flutter/material.dart';

import '../core/constants/app_routes.dart';
import '../core/theme/upnest_theme.dart';

// ================= AUTH =================
import '../features/auth/presentation/login_page.dart';

// ================= ADMIN =================
import '../features/admin/presentation/admin_home_page.dart';

// ================= LECTURER =================
import '../features/lecturer/presentation/lecturer_home_page.dart';

// ================= STUDENT =================
import '../features/student/presentation/student_home_page.dart';

class UpnestEduApp extends StatelessWidget {
  const UpnestEduApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UpNest Edu',
      debugShowCheckedModeBanner: false,
      theme: UpnestTheme.light(),

      // 🔑 Entry point
      initialRoute: UpnestRoutes.login,

      routes: {
        // ===== AUTH =====
        UpnestRoutes.login: (_) => const LoginPage(),

        // ===== ADMIN =====
        UpnestRoutes.adminHome: (_) => const AdminHomePage(),

        // ===== LECTURER =====
        // RoleShell + menu (dashboard, lớp đang dạy, ...)
        UpnestRoutes.lecturerHome: (_) => const LecturerHomePage(),

        // ===== STUDENT =====
        // RoleShell + menu (đăng ký lớp, lớp của tôi, ...)
        UpnestRoutes.studentHome: (_) => const StudentDashboardPage(),
      },
    );
  }
}
