import 'package:flutter/material.dart';
import 'package:upnest_edu/core/mock/app_mock_db.dart';

import '../grades/student_grading.dart';
import 'student_class_detail_page.dart';
import 'student_class_models.dart';

class MyClassesPage extends StatefulWidget {
  const MyClassesPage({super.key});

  @override
  State<MyClassesPage> createState() => _MyClassesPageState();
}

class _MyClassesPageState extends State<MyClassesPage> {
  // tạm thời: student hiện tại
  String get _studentUsername => 'sv01';

  List<StudentEnrollment> get _rows {
    final myClassIds = AppMockDb.enrollments
        .where((e) => (e['studentUsername'] as String).toLowerCase() == _studentUsername.toLowerCase())
        .map((e) => e['classId'] as int)
        .toList();

    return myClassIds.map((classId) {
      final c = AppMockDb.classById(classId)!;

      final g = AppMockDb.gradeOf(classId: classId, studentUsername: _studentUsername);
      final attRate = AppMockDb.attendancePercent(classId: classId, studentUsername: _studentUsername);

      final lecturerUsername = (c['lecturerUsername'] ?? '').toString();
      final lecturerName = AppMockDb.fullNameOf(lecturerUsername);

      final anns = AppMockDb.announcementsOfClass(classId);
      final lastAnn = anns.isEmpty ? null : (anns.first['title'] ?? '').toString() + ': ' + (anns.first['content'] ?? '').toString();

      return StudentEnrollment(
        classId: classId,
        classCode: (c['code'] ?? '').toString(),
        className: (c['name'] ?? '').toString(),
        subjectCode: (c['subjectCode'] ?? '').toString(),
        subjectName: (c['subjectName'] ?? '').toString(),
        lecturerName: lecturerName.isEmpty ? lecturerUsername : lecturerName,
        midterm: g['midterm'],
        finalExam: g['final'],
        attendanceRate: attRate,
        lastAnnouncement: lastAnn,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final rows = _rows;

    Widget card(Widget child) => Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: cs.outlineVariant.withOpacity(0.6)),
          ),
          child: Padding(padding: const EdgeInsets.all(12), child: child),
        );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lớp của tôi',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Expanded(
            child: card(
              rows.isEmpty
                  ? const Center(child: Text('Bạn chưa đăng ký lớp nào'))
                  : ListView.separated(
                      itemCount: rows.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final c = rows[i];
                        final avg = StudentGrading.average(c.midterm, c.finalExam);
                        final letter = StudentGrading.letter(avg);
                        final pass = StudentGrading.isPass(avg);

                        return ListTile(
                          title: Text('${c.className}'),
                          subtitle: Text('${c.classCode} • ${c.subjectCode} - ${c.subjectName}\nGV: ${c.lecturerName}'),
                          isThreeLine: true,
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('TB: ${avg?.toStringAsFixed(1) ?? '-'} ($letter)'),
                              Text(
                                pass ? 'Đậu' : 'Chưa đạt',
                                style: TextStyle(
                                  color: pass ? Colors.green[700] : Colors.red[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => StudentClassDetailPage(enrollment: c)),
                            );
                            setState(() {});
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
