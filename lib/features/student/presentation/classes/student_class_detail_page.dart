import 'package:flutter/material.dart';
import 'package:upnest_edu/core/mock/app_mock_db.dart';

import '../grades/student_grading.dart';
import 'student_class_models.dart';

class StudentClassDetailPage extends StatelessWidget {
  final StudentEnrollment enrollment;
  const StudentClassDetailPage({super.key, required this.enrollment});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final avg = StudentGrading.average(enrollment.midterm, enrollment.finalExam);
    final letter = StudentGrading.letter(avg);
    final rank = StudentGrading.rankVi(avg);
    final pass = StudentGrading.isPass(avg);
    final attPercent = (enrollment.attendanceRate * 100).round();

    // dùng dữ liệu chung announcements theo classId (đảm bảo đồng bộ)
    final anns = AppMockDb.announcementsOfClass(enrollment.classId);

    Widget card(Widget child) => Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: cs.outlineVariant.withOpacity(0.6)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(enrollment.classCode),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              height: 36,
              child: TextButton(
                onPressed: null, // tạm thời khóa để demo ổn định
                child: Text(
                  'Huỷ đăng ký',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              enrollment.className,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text('${enrollment.subjectCode} - ${enrollment.subjectName}'),
            const SizedBox(height: 8),
            Text('Giảng viên: ${enrollment.lecturerName}'),
            const SizedBox(height: 12),

            // ===== KẾT QUẢ =====
            card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kết quả học tập', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: Text('Giữa kỳ: ${enrollment.midterm?.toStringAsFixed(1) ?? '-'}')),
                      Expanded(child: Text('Cuối kỳ: ${enrollment.finalExam?.toStringAsFixed(1) ?? '-'}')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Trung bình: ${avg?.toStringAsFixed(1) ?? '-'}  •  Xếp loại: $letter ($rank)',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    pass ? 'Trạng thái: ĐẬU' : 'Trạng thái: CHƯA ĐẠT',
                    style: TextStyle(
                      color: pass ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ===== CHUYÊN CẦN =====
            card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Chuyên cần', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: enrollment.attendanceRate.clamp(0, 1),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  const SizedBox(height: 8),
                  Text('Tỉ lệ có mặt: $attPercent%'),
                  if (attPercent < 80)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Cảnh báo: chuyên cần thấp, cần đi học đều hơn.',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ===== THÔNG BÁO =====
            card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Thông báo lớp', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  if (anns.isEmpty)
                    const Text('Chưa có thông báo.')
                  else
                    ...anns.map((a) {
                      final title = (a['title'] ?? '').toString();
                      final content = (a['content'] ?? '').toString();
                      final createdAt = a['createdAt'] as DateTime;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(content),
                            const SizedBox(height: 4),
                            Text(
                              _fmtDateTime(createdAt),
                              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
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
