import 'package:flutter/material.dart';

//package import
import 'package:upnest_edu/core/layout/role_destination.dart';
import 'package:upnest_edu/core/layout/role_shell.dart';

import 'dashboard/lecturer_dashboard_page.dart';
import 'classes/lecturer_classes_page.dart';

class LecturerHomePage extends StatelessWidget {
  const LecturerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleShell(
      appBarTitle: 'UpNest Edu - Giảng viên',
      sideTitle: 'Bảng điều khiển GV',
      sideHeaderColor: const Color(0xFF16A34A),
      destinations: const [
        RoleDestination(
          icon: Icons.dashboard_outlined,
          label: 'Tổng quan',
          builder: _LecturerBuilders.dashboard,
        ),
        RoleDestination(
          icon: Icons.school_outlined,
          label: 'Lớp đang dạy',
          builder: _LecturerBuilders.classes,
        ),
      ],
    );
  }
}

class _LecturerBuilders {
  static Widget dashboard(BuildContext _) => const LecturerDashboardPage();
  static Widget classes(BuildContext _) => const LecturerClassesPage();
}
