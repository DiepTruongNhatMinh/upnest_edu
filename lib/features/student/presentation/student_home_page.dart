import 'package:flutter/material.dart';
import 'package:upnest_edu/core/mock/app_mock_db.dart';

class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key});

  // Tạm thời gán student đang đăng nhập.
  // Sau này lấy từ AuthService (username/userId).
  String get _studentUsername => 'sv01';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final fullName = AppMockDb.fullNameOf(_studentUsername);

    // lớp của student = enrollments theo classId
    final myClassIds = AppMockDb.enrollments
        .where((e) => (e['studentUsername'] as String).toLowerCase() == _studentUsername.toLowerCase())
        .map((e) => e['classId'] as int)
        .toList();

    final totalClasses = myClassIds.length;

    // tính TB chung (bình quân TB từng lớp có điểm)
    double sum = 0;
    int cnt = 0;
    for (final classId in myClassIds) {
      final g = AppMockDb.gradeOf(classId: classId, studentUsername: _studentUsername);
      final m = g['midterm'];
      final f = g['final'];
      if (m == null && f == null) continue;

      // giống lecturer: 40/60 (để consistent)
      final avg = ( (m ?? 0) * 0.4 ) + ( (f ?? 0) * 0.6 );
      sum += avg;
      cnt++;
    }
    final overallAvg = cnt == 0 ? null : sum / cnt;

    // chuyên cần chung
    double attSum = 0;
    for (final classId in myClassIds) {
      attSum += AppMockDb.attendancePercent(classId: classId, studentUsername: _studentUsername);
    }
    final overallAtt = myClassIds.isEmpty ? 0 : attSum / myClassIds.length;

    // thông báo mới nhất: lấy announcement mới nhất trong các lớp của student
    Map<String, dynamic>? latest;
    for (final classId in myClassIds) {
      final anns = AppMockDb.announcementsOfClass(classId);
      if (anns.isEmpty) continue;
      final top = anns.first;
      if (latest == null) {
        latest = top;
      } else {
        final a = (top['createdAt'] as DateTime);
        final b = (latest['createdAt'] as DateTime);
        if (a.isAfter(b)) latest = top;
      }
    }

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
          Text('Xin chào $fullName'),
          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(
                title: 'Lớp đã đăng ký',
                value: '$totalClasses',
                icon: Icons.school_outlined,
                cs: cs,
              ),
              _StatCard(
                title: 'Điểm trung bình',
                value: overallAvg == null ? '-' : overallAvg.toStringAsFixed(1),
                icon: Icons.grade_outlined,
                cs: cs,
              ),
              _StatCard(
                title: 'Chuyên cần',
                value: '${(overallAtt * 100).round()}%',
                icon: Icons.how_to_reg_outlined,
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
                    child: _MyRecentClasses(studentUsername: _studentUsername),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _Panel(
                    cs: cs,
                    title: 'Thông báo mới nhất',
                    child: latest == null
                        ? const Center(child: Text('Chưa có thông báo'))
                        : Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (latest['title'] ?? '').toString(),
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text((latest['content'] ?? '').toString()),
                                const SizedBox(height: 10),
                                Text(
                                  _fmtDateTime(latest['createdAt'] as DateTime),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
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

  static String _fmtDateTime(DateTime d) {
    String two(int x) => x.toString().padLeft(2, '0');
    final dd = two(d.day);
    final mm = two(d.month);
    final yy = d.year.toString();
    final hh = two(d.hour);
    final mi = two(d.minute);
    return '$dd/$mm/$yy $hh:$mi';
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

class _MyRecentClasses extends StatelessWidget {
  final String studentUsername;
  const _MyRecentClasses({required this.studentUsername});

  @override
  Widget build(BuildContext context) {
    final myClassIds = AppMockDb.enrollments
        .where((e) => (e['studentUsername'] as String).toLowerCase() == studentUsername.toLowerCase())
        .map((e) => e['classId'] as int)
        .toList();

    final rows = myClassIds
        .map((id) => AppMockDb.classById(id))
        .whereType<Map<String, dynamic>>()
        .toList();

    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final c = rows[i];
        final classId = c['id'] as int;

        final g = AppMockDb.gradeOf(classId: classId, studentUsername: studentUsername);
        final m = g['midterm'];
        final f = g['final'];
        final avg = (m == null && f == null) ? null : ((m ?? 0) * 0.4 + (f ?? 0) * 0.6);

        final att = (AppMockDb.attendancePercent(classId: classId, studentUsername: studentUsername) * 100).round();

        return ListTile(
          dense: true,
          title: Text((c['name'] ?? '').toString()),
          subtitle: Text('${c['code']} • ${c['subjectCode']} - ${c['subjectName']}'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('TB: ${avg?.toStringAsFixed(1) ?? '-'}'),
              Text('CC: $att%'),
            ],
          ),
        );
      },
    );
  }
}
