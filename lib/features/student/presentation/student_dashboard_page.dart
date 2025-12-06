import 'package:flutter/material.dart';

class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key});

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature: đang phát triển...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UpNest Edu - Sinh viên'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF97316), Color(0xFFEC4899)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Sinh viên',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.event_note_outlined),
              title: const Text('Lịch học'),
              onTap: () => _showComingSoon(context, 'Lịch học'),
            ),
            ListTile(
              leading: const Icon(Icons.class_outlined),
              title: const Text('Lớp đã đăng ký'),
              onTap: () => _showComingSoon(context, 'Lớp đã đăng ký'),
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events_outlined),
              title: const Text('Kết quả học tập'),
              onTap: () => _showComingSoon(context, 'Kết quả học tập'),
            ),
            ListTile(
              leading: const Icon(Icons.folder_shared_outlined),
              title: const Text('Tài liệu học tập'),
              onTap: () => _showComingSoon(context, 'Tài liệu học tập'),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Dashboard Sinh viên - Thông tin học tập'),
      ),
    );
  }
}
