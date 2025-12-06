import 'package:flutter/material.dart';
import '../../../core/layout/role_destination.dart';
import '../../../core/layout/role_shell.dart';

class LecturerDashboardPage extends StatelessWidget {
  const LecturerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleShell(
      appBarTitle: 'UpNest Edu - Giảng viên',
      sideTitle: 'Giảng viên',
      sideHeaderColor: const Color(0xFF10B981), // màu xanh như hình
      destinations: [
        RoleDestination(
          icon: Icons.dashboard_customize_outlined,
          label: 'Tổng quan lớp học',
          builder: (_) => const Center(
            child: Text('Dashboard Giảng viên - Tổng quan lớp học'),
          ),
        ),
        RoleDestination(
          icon: Icons.class_outlined,
          label: 'Danh sách lớp của tôi',
          builder: (_) => const Center(
            child: Text('Giảng viên - Danh sách lớp của tôi'),
          ),
        ),
        RoleDestination(
          icon: Icons.assignment_turned_in_outlined,
          label: 'Điểm & đánh giá',
          builder: (_) => const Center(
            child: Text('Giảng viên - Điểm & đánh giá'),
          ),
        ),
        RoleDestination(
          icon: Icons.folder_open_outlined,
          label: 'Tài liệu giảng dạy',
          builder: (_) => const Center(
            child: Text('Giảng viên - Tài liệu giảng dạy'),
          ),
        ),
      ],
    );
  }
}
