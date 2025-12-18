import 'dart:async';
import 'package:flutter/material.dart';
import '../student_state.dart';

class CourseCatalogPage extends StatefulWidget {
  const CourseCatalogPage({super.key});

  @override
  State<CourseCatalogPage> createState() => _CourseCatalogPageState();
}

class _CourseCatalogPageState extends State<CourseCatalogPage> {
  final _kwCtrl = TextEditingController();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _kwCtrl.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final total = d.inSeconds;
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(h)}:${two(m)}:${two(s)}';
  }

  Widget _pill({
    required String text,
    required Color bg,
    required Color border,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final kw = _kwCtrl.text.trim().toLowerCase();
    final rows = StudentState.I.catalog.where((c) {
      if (kw.isEmpty) return true;
      return c.classCode.toLowerCase().contains(kw) ||
          c.className.toLowerCase().contains(kw) ||
          c.subjectCode.toLowerCase().contains(kw) ||
          c.subjectName.toLowerCase().contains(kw);
    }).toList();

    final toolbar = Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          runSpacing: 12,
          spacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 560,
              child: TextField(
                controller: _kwCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tìm mã lớp / môn học',
                  hintText: 'Ví dụ: MATH, ENG-12C3, Toán...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
              ),
              child: Text(
                'Quy định: 3 ngày kể từ lúc Admin tạo lịch học',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đăng ký môn / lớp',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          toolbar,
          const SizedBox(height: 12),
          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: cs.outlineVariant.withOpacity(0.6)),
              ),
              child: rows.isEmpty
                  ? const Center(child: Text('Không có lớp để đăng ký'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: rows.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 18,
                        color: cs.outlineVariant.withOpacity(0.6),
                      ),
                      itemBuilder: (context, i) {
                        final c = rows[i];

                        final enrolled = StudentState.I.isEnrolled(c.classId);
                        final full = c.enrolled >= c.capacity;

                        final canChange = StudentState.I.canChangeEnrollment(c.classId);
                        final remaining = StudentState.I.remainingChangeTime(c.classId);

                        Widget statusPill;
                        if (!canChange) {
                          statusPill = _pill(
                            text: 'ĐÃ KHÓA',
                            bg: const Color(0xFFF1F3F5),
                            border: const Color(0xFFD0D7DE),
                            fg: const Color(0xFF57606A),
                          );
                        } else if (enrolled) {
                          statusPill = _pill(
                            text: 'ĐÃ ĐĂNG KÝ',
                            bg: const Color(0xFFE8F5E9),
                            border: const Color(0xFFB7E1C1),
                            fg: const Color(0xFF1B5E20),
                          );
                        } else if (full) {
                          statusPill = _pill(
                            text: 'ĐÃ ĐỦ CHỖ',
                            bg: const Color(0xFFFDECEA),
                            border: const Color(0xFFF5C2C7),
                            fg: const Color(0xFF842029),
                          );
                        } else {
                          statusPill = _pill(
                            text: 'CÒN CHỖ',
                            bg: const Color(0xFFEFF6FF),
                            border: const Color(0xFFB6D4FE),
                            fg: const Color(0xFF084298),
                          );
                        }

                        final rightTopText = canChange ? 'Còn ${_fmt(remaining)}' : 'Đã quá 3 ngày';

                        Widget action;
                        if (enrolled) {
                          action = SizedBox(
                            width: 170,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  rightTopText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: cs.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 36,
                                  child: OutlinedButton(
                                    onPressed: canChange
                                        ? () {
                                            final r = StudentState.I.drop(c.classId);
                                            setState(() {});
                                            if (r == DropResult.ok) {
                                              _toast('Đã huỷ đăng ký');
                                            } else if (r == DropResult.locked) {
                                              _toast('Đã khóa huỷ đăng ký');
                                            }
                                          }
                                        : null,
                                    child: const Text('Huỷ đăng ký'),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          final disabledReason = !canChange
                              ? 'Đã khóa đăng ký'
                              : full
                                  ? 'Lớp đã đủ chỗ'
                                  : null;

                          action = SizedBox(
                            width: 170,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  rightTopText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: cs.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 36,
                                  child: FilledButton(
                                    onPressed: (canChange && !full)
                                        ? () {
                                            final r = StudentState.I.enroll(c.classId);
                                            setState(() {});
                                            if (r == EnrollResult.ok) {
                                              _toast('Đăng ký thành công');
                                            } else if (r == EnrollResult.locked) {
                                              _toast('Đã khóa đăng ký');
                                            } else if (r == EnrollResult.full) {
                                              _toast('Lớp đã đủ chỗ');
                                            } else if (r == EnrollResult.already) {
                                              _toast('Bạn đã đăng ký lớp này');
                                            }
                                          }
                                        : null,
                                    child: Text(disabledReason ?? 'Đăng ký'),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      runSpacing: 8,
                                      spacing: 10,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          '${c.subjectCode} - ${c.subjectName}',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        Text(
                                          c.classCode,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: cs.onSurfaceVariant,
                                          ),
                                        ),
                                        statusPill,
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(c.className, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text(
                                      'GV: ${c.lecturerName} • ${c.scheduleText}',
                                      style: TextStyle(color: cs.onSurfaceVariant),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Sĩ số: ${c.enrolled}/${c.capacity}',
                                      style: TextStyle(color: cs.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              action,
                            ],
                          ),
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
