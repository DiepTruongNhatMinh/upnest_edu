import 'package:flutter/material.dart';
import '../../../core/layout/role_destination.dart';
import '../../../core/layout/role_shell.dart';

import 'dashboard/admin_dashboard_page.dart';
import 'users/admin_users_page.dart';
import 'classes/admin_classes_page.dart';
import 'stats/admin_stats_page.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleShell(
      appBarTitle: 'UpNest Edu - Admin',
      sideTitle: 'Quản trị hệ thống',
      sideHeaderColor: const Color(0xFF2563EB),
      destinations: const [
        RoleDestination(
          icon: Icons.dashboard_outlined,
          label: 'Tổng quan',
          builder: _AdminBuilders.dashboard,
        ),
        RoleDestination(
          icon: Icons.people_outline,
          label: 'Quản lý người dùng',
          builder: _AdminBuilders.users,
        ),
        RoleDestination(
          icon: Icons.school_outlined,
          label: 'Quản lý lớp / môn',
          builder: _AdminBuilders.classes,
        ),
        RoleDestination(
          icon: Icons.analytics_outlined,
          label: 'Báo cáo & thống kê',
          builder: _AdminBuilders.stats,
        ),
      ],
    );
  }
}

class _AdminBuilders {
  static Widget dashboard(BuildContext _) => const AdminDashboardPage();
  static Widget users(BuildContext _) => const AdminUsersPage();
  static Widget classes(BuildContext _) => const AdminClassesPage();
  static Widget stats(BuildContext _) => const AdminStatsPage();
}
