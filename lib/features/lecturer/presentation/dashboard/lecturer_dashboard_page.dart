import 'package:flutter/material.dart';
import 'package:upnest_edu/core/mock/app_mock_db.dart';

class LecturerDashboardPage extends StatelessWidget {
  const LecturerDashboardPage({super.key});

  // Tạm thời: gán lecturer hiện tại.
  // Sau này bạn có thể lấy từ AuthService (username/userId) rồi map ra username.
  String get _lecturerUsername => 'gv01';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final fullName = AppMockDb.fullNameOf(_lecturerUsername);
    final totalClasses = AppMockDb.classesCountForLecturer(_lecturerUsername);
    final totalStudents = AppMockDb.studentsCountForLecturer(_lecturerUsername);
    final todaySessions = AppMockDb.sessionsTodayForLecturer(_lecturerUsername);
    final pendingGrades = AppMockDb.pendingGradesForLecturer(_lecturerUsername);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng quan',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Xin chào $fullName',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),

          // Cards
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(
                title: 'Lớp đang dạy',
                value: '$totalClasses',
                icon: Icons.school_outlined,
                cs: cs,
              ),
              _StatCard(
                title: 'Sinh viên phụ trách',
                value: '$totalStudents',
                icon: Icons.people_outline,
                cs: cs,
              ),
              _StatCard(
                title: 'Buổi học hôm nay',
                value: '$todaySessions',
                icon: Icons.event_available_outlined,
                cs: cs,
              ),
              _StatCard(
                title: 'Chưa nhập điểm',
                value: '$pendingGrades',
                icon: Icons.edit_note_outlined,
                cs: cs,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _Panel(
                    cs: cs,
                    title: 'Lớp gần đây',
                    child: _RecentClasses(lecturerUsername: _lecturerUsername),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _Panel(
                    cs: cs,
                    title: 'Việc cần làm',
                    child: _TodoPanel(
                      cs: cs,
                      pendingGrades: pendingGrades,
                      todaySessions: todaySessions,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final ColorScheme cs;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 92,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cs.outlineVariant.withOpacity(0.6)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.bodyMedium!,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final ColorScheme cs;
  final String title;
  final Widget child;

  const _Panel({
    required this.cs,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _RecentClasses extends StatelessWidget {
  final String lecturerUsername;
  const _RecentClasses({required this.lecturerUsername});

  @override
  Widget build(BuildContext context) {
    final classes = AppMockDb.classesForLecturer(lecturerUsername);

    return ListView.separated(
      itemCount: classes.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final c = classes[i];
        final classId = c['id'] as int;
        final stCount = AppMockDb.studentsInClass(classId).length;

        return ListTile(
          dense: true,
          title: Text((c['name'] ?? '').toString()),
          subtitle: Text('${c['code']} • ${c['subjectCode']} - ${c['subjectName']} • Sĩ số: $stCount'),
          trailing: Text((c['status'] ?? '').toString() == 'ACTIVE' ? 'Đang dạy' : 'Kết thúc'),
        );
      },
    );
  }
}

class _TodoPanel extends StatelessWidget {
  final ColorScheme cs;
  final int pendingGrades;
  final int todaySessions;

  const _TodoPanel({
    required this.cs,
    required this.pendingGrades,
    required this.todaySessions,
  });

  @override
  Widget build(BuildContext context) {
    final items = <String>[
      if (todaySessions > 0) 'Có $todaySessions buổi học hôm nay',
      if (pendingGrades > 0) 'Còn $pendingGrades sinh viên chưa có điểm',
      'Cập nhật thông báo cho lớp nếu cần',
    ];

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(items[i])),
          ],
        );
      },
    );
  }
}
