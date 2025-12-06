import 'package:flutter/material.dart';
import '../../../core/layout/role_destination.dart';
import '../../../core/layout/role_shell.dart';

class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleShell(
      appBarTitle: 'UpNest Edu - Sinh viên',
      sideTitle: 'Sinh viên',
      sideHeaderColor: const Color(0xFFF97316), // cam hồng cho student
      destinations: [
        RoleDestination(
          icon: Icons.event_note_outlined,
          label: 'Lịch học',
          builder: (_) => const Center(
            child: Text('Sinh viên - Lịch học'),
          ),
        ),
        RoleDestination(
          icon: Icons.class_outlined,
          label: 'Lớp đã đăng ký',
          builder: (_) => const Center(
            child: Text('Sinh viên - Lớp đã đăng ký'),
          ),
        ),
        RoleDestination(
          icon: Icons.emoji_events_outlined,
          label: 'Kết quả học tập',
          builder: (_) => const Center(
            child: Text('Sinh viên - Kết quả học tập'),
          ),
        ),
        RoleDestination(
          icon: Icons.folder_shared_outlined,
          label: 'Tài liệu học tập',
          builder: (_) => const Center(
            child: Text('Sinh viên - Tài liệu học tập'),
          ),
        ),
      ],
    );
  }
}
