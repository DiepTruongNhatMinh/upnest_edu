import 'package:flutter/material.dart';
import '../../../core/layout/role_destination.dart';
import '../../../core/layout/role_shell.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleShell(
      appBarTitle: 'UpNest Edu - Admin',
      sideTitle: 'Quản trị hệ thống',
      sideHeaderColor: const Color(0xFF2563EB), // xanh dương admin
      destinations: [
        RoleDestination(
          icon: Icons.dashboard_outlined,
          label: 'Tổng quan',
          builder: (_) => const Center(
            child: Text('Admin - Tổng quan hệ thống'),
          ),
        ),
        RoleDestination(
          icon: Icons.people_outline,
          label: 'Quản lý người dùng',
          builder: (_) => const Center(
            child: Text('Admin - Quản lý người dùng'),
          ),
        ),
        RoleDestination(
          icon: Icons.school_outlined,
          label: 'Quản lý lớp / môn',
          builder: (_) => const Center(
            child: Text('Admin - Quản lý lớp / môn'),
          ),
        ),
        RoleDestination(
          icon: Icons.analytics_outlined,
          label: 'Báo cáo & thống kê',
          builder: (_) => const Center(
            child: Text('Admin - Báo cáo & thống kê'),
          ),
        ),
      ],
    );
  }
}
