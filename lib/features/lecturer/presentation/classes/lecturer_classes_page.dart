import 'package:flutter/material.dart';
import 'package:upnest_edu/core/mock/app_mock_db.dart';

import 'lecturer_class_model.dart';
import 'lecturer_class_detail_page.dart';

class LecturerClassesPage extends StatefulWidget {
  const LecturerClassesPage({super.key});

  @override
  State<LecturerClassesPage> createState() => _LecturerClassesPageState();
}

class _LecturerClassesPageState extends State<LecturerClassesPage> {
  final _keywordCtrl = TextEditingController();

  // Tạm thời: gv đang đăng nhập
  String get _lecturerUsername => 'gv01';

  List<LecturerClass> get _classes {
    final rows = AppMockDb.classesForLecturer(_lecturerUsername);
    return rows.map((c) {
      return LecturerClass(
        id: (c['id'] as int),
        code: (c['code'] ?? '').toString(),
        name: (c['name'] ?? '').toString(),
        subjectCode: (c['subjectCode'] ?? '').toString(),
        subjectName: (c['subjectName'] ?? '').toString(),
      );
    }).toList();
  }

  @override
  void dispose() {
    _keywordCtrl.dispose();
    super.dispose();
  }

  List<LecturerClass> get _filtered {
    final kw = _keywordCtrl.text.trim().toLowerCase();
    final list = _classes;

    if (kw.isEmpty) return list;
    return list.where((c) {
      return c.code.toLowerCase().contains(kw) ||
          c.name.toLowerCase().contains(kw) ||
          c.subjectCode.toLowerCase().contains(kw) ||
          c.subjectName.toLowerCase().contains(kw);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final rows = _filtered;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lớp đang dạy',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: cs.outlineVariant.withOpacity(0.6)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _keywordCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tìm mã lớp / tên lớp / môn học',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: cs.outlineVariant.withOpacity(0.6)),
              ),
              child: rows.isEmpty
                  ? const Center(child: Text('Không có lớp'))
                  : ListView.separated(
                      itemCount: rows.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final c = rows[i];
                        final stCount = AppMockDb.studentsInClass(c.id).length;

                        return ListTile(
                          title: Text(c.name),
                          subtitle: Text('${c.code} • ${c.subjectCode} - ${c.subjectName} • Sĩ số: $stCount'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LecturerClassDetailPage(clazz: c),
                              ),
                            );
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
