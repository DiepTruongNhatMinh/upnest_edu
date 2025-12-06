import 'package:flutter/material.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature: đang phát triển...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UpNest Edu - Admin'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Quản trị hệ thống',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Tổng quan'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Quản lý người dùng'),
              onTap: () => _showComingSoon(context, 'Quản lý người dùng'),
            ),
            ListTile(
              leading: const Icon(Icons.school_outlined),
              title: const Text('Quản lý lớp / khóa học'),
              onTap: () => _showComingSoon(context, 'Quản lý lớp / khóa học'),
            ),
            ListTile(
              leading: const Icon(Icons.analytics_outlined),
              title: const Text('Báo cáo & thống kê'),
              onTap: () => _showComingSoon(context, 'Báo cáo & thống kê'),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Dashboard Admin - Tổng quan hệ thống'),
      ),
    );
  }
}
