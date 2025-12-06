import 'package:flutter/material.dart';

import '../core/constants/app_routes.dart';
import '../core/theme/upnest_theme.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/admin/presentation/admin_dashboard_page.dart';
import '../features/lecturer/presentation/lecturer_dashboard_page.dart';
import '../features/student/presentation/student_dashboard_page.dart';

class UpnestEduApp extends StatelessWidget {
  const UpnestEduApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UpNest Edu',
      debugShowCheckedModeBanner: false,
      theme: UpnestTheme.light(),
      initialRoute: UpnestRoutes.login,
      routes: {
        UpnestRoutes.login: (_) => const LoginPage(),
        UpnestRoutes.adminHome: (_) => const AdminDashboardPage(),
        UpnestRoutes.lecturerHome: (_) => const LecturerDashboardPage(),
        UpnestRoutes.studentHome: (_) => const StudentDashboardPage(),
      },
    );
  }
}
