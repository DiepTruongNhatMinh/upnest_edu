import 'package:flutter/material.dart';

class LecturerDashboardPage extends StatelessWidget {
  const LecturerDashboardPage({super.key});

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature: đang phát triển...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UpNest Edu - Giảng viên'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Giảng viên',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_customize_outlined),
              title: const Text('Tổng quan lớp học'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.class_outlined),
              title: const Text('Danh sách lớp của tôi'),
              onTap: () => _showComingSoon(context, 'Danh sách lớp'),
            ),
            ListTile(
              leading: const Icon(Icons.assignment_turned_in_outlined),
              title: const Text('Điểm & đánh giá'),
              onTap: () => _showComingSoon(context, 'Điểm & đánh giá'),
            ),
            ListTile(
              leading: const Icon(Icons.folder_open_outlined),
              title: const Text('Tài liệu giảng dạy'),
              onTap: () => _showComingSoon(context, 'Tài liệu giảng dạy'),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Dashboard Giảng viên - Tổng quan lớp học'),
      ),
    );
  }
}
