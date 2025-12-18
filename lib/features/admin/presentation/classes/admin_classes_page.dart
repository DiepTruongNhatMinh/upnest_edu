import 'package:flutter/material.dart';
import '../subjects/admin_subjects_page.dart';
import 'admin_classes_list_page.dart';

class AdminClassesPage extends StatelessWidget {
  const AdminClassesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(),
            SizedBox(height: 12),
            TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Môn học'),
                Tab(text: 'Lớp học'),
              ],
            ),
            SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                children: [
                  AdminSubjectsPage(),
                  AdminClassesListPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quản lý lớp / môn',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Quản lý danh mục môn học và lớp học.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
