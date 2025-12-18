import 'package:flutter/material.dart';
import 'admin_class_model.dart';
import 'admin_class_form_page.dart';
import 'admin_class_detail_page.dart';

class AdminClassesListPage extends StatefulWidget {
  const AdminClassesListPage({super.key});

  @override
  State<AdminClassesListPage> createState() => _AdminClassesListPageState();
}

class _AdminClassesListPageState extends State<AdminClassesListPage> {
  final _keywordCtrl = TextEditingController();

  String _activeFilter = 'ALL';
  String _subjectFilter = 'ALL';

  // ✅ mock data
  List<AdminClass> _classes = const [
    AdminClass(
      id: 1,
      code: 'MATH-10A1',
      name: 'Toán 10A1',
      subjectCode: 'MATH',
      subjectName: 'Toán',
      lecturer: 'gv01',
      isActive: true,
    ),
    AdminClass(
      id: 2,
      code: 'PHY-11B2',
      name: 'Vật lý 11B2',
      subjectCode: 'PHY',
      subjectName: 'Vật lý',
      lecturer: 'gv02',
      isActive: true,
    ),
    AdminClass(
      id: 3,
      code: 'ENG-12C3',
      name: 'Tiếng Anh 12C3',
      subjectCode: 'ENG',
      subjectName: 'Tiếng Anh',
      lecturer: 'gv01',
      isActive: false,
    ),
    AdminClass(
      id: 4,
      code: 'CHEM-10B1',
      name: 'Hóa học 10B1',
      subjectCode: 'CHEM',
      subjectName: 'Hóa học',
      lecturer: 'gv02',
      isActive: true,
    ),
    AdminClass(
      id: 5,
      code: 'BIO-12A2',
      name: 'Sinh học 12A2',
      subjectCode: 'BIO',
      subjectName: 'Sinh học',
      lecturer: 'gv01',
      isActive: true,
    ),
  ];

  // mock list môn để filter/select
  final List<Map<String, String>> _subjects = const [
    {'code': 'MATH', 'name': 'Toán'},
    {'code': 'PHY', 'name': 'Vật lý'},
    {'code': 'ENG', 'name': 'Tiếng Anh'},
    {'code': 'CHEM', 'name': 'Hóa học'},
    {'code': 'BIO', 'name': 'Sinh học'},
  ];

  @override
  void dispose() {
    _keywordCtrl.dispose();
    super.dispose();
  }

  List<AdminClass> get _filtered {
    final kw = _keywordCtrl.text.trim().toLowerCase();

    return _classes.where((c) {
      final matchKw = kw.isEmpty ||
          c.code.toLowerCase().contains(kw) ||
          c.name.toLowerCase().contains(kw) ||
          c.lecturer.toLowerCase().contains(kw);

      final matchActive = _activeFilter == 'ALL' ||
          (_activeFilter == 'ACTIVE' && c.isActive) ||
          (_activeFilter == 'INACTIVE' && !c.isActive);

      final matchSubject = _subjectFilter == 'ALL' || c.subjectCode == _subjectFilter;

      return matchKw && matchActive && matchSubject;
    }).toList();
  }

  Widget _statusChip(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE8F5E9) : const Color(0xFFFDECEA),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active ? const Color(0xFFB7E1C1) : const Color(0xFFF5C2C7),
        ),
      ),
      child: Text(
        active ? 'ACTIVE' : 'INACTIVE',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: active ? const Color(0xFF1B5E20) : const Color(0xFF842029),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  void _toggleActive(AdminClass c) {
    setState(() {
      _classes = _classes.map((x) => x.id == c.id ? x.copyWith(isActive: !x.isActive) : x).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(c.isActive ? 'Đã khoá lớp' : 'Đã kích hoạt lớp')),
    );
  }

  Future<void> _openCreate() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminClassFormPage(subjects: _subjects),
      ),
    );

    if (ok == true) {
      setState(() {
        final maxId = _classes.map((e) => e.id).fold<int>(0, (a, b) => a > b ? a : b);
        final nextId = maxId + 1;

        final s = _subjects.first;
        _classes = [
          ..._classes,
          AdminClass(
            id: nextId,
            code: 'NEW-$nextId',
            name: 'Lớp mới $nextId',
            subjectCode: s['code']!,
            subjectName: s['name']!,
            lecturer: 'gv01',
            isActive: true,
          ),
        ];
      });
    }
  }

  Future<void> _openEdit(AdminClass c) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminClassFormPage(
          subjects: _subjects,
          initial: c,
        ),
      ),
    );

    if (ok == true) {
      setState(() {
        _classes = _classes.map((x) => x.id == c.id ? x.copyWith(name: '${x.name} (edited)') : x).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = _filtered;
    final cs = Theme.of(context).colorScheme;

    Widget card(Widget child) => Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: cs.outlineVariant.withOpacity(0.6)),
          ),
          child: child,
        );

    final subjectItems = <DropdownMenuItem<String>>[
      const DropdownMenuItem(value: 'ALL', child: Text('Tất cả môn')),
      ..._subjects.map((s) {
        return DropdownMenuItem(
          value: s['code'],
          child: Text('${s['code']} - ${s['name']}'),
        );
      }),
    ];

    final toolbar = card(
      Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          runSpacing: 12,
          spacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 520,
              child: TextField(
                controller: _keywordCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tìm mã lớp / tên lớp / giảng viên',
                  hintText: 'Ví dụ: 10A1, Toán, gv01',
                  border: OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            SizedBox(
              width: 240,
              child: DropdownButtonFormField<String>(
                value: _subjectFilter,
                decoration: const InputDecoration(
                  labelText: 'Môn học',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: subjectItems,
                onChanged: (v) => setState(() => _subjectFilter = v ?? 'ALL'),
              ),
            ),
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<String>(
                value: _activeFilter,
                decoration: const InputDecoration(
                  labelText: 'Trạng thái',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('Tất cả')),
                  DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
                  DropdownMenuItem(value: 'INACTIVE', child: Text('Inactive')),
                ],
                onChanged: (v) => setState(() => _activeFilter = v ?? 'ALL'),
              ),
            ),
            SizedBox(
              height: 40,
              child: FilledButton.icon(
                onPressed: _openCreate,
                icon: const Icon(Icons.add),
                label: const Text('Thêm lớp học'),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Tổng: ${rows.length}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        toolbar,
        const SizedBox(height: 12),
        Expanded(
          child: card(
            rows.isEmpty
                ? const Center(child: Text('Không có dữ liệu'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: DataTable(
                      headingRowHeight: 48,
                      dataRowMinHeight: 52,
                      dataRowMaxHeight: 56,
                      columnSpacing: 24,
                      dividerThickness: 0.6,
                      headingTextStyle:
                          Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Mã lớp')),
                        DataColumn(label: Text('Tên lớp')),
                        DataColumn(label: Text('Môn học')),
                        DataColumn(label: Text('Giảng viên')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Hành động')),
                      ],
                      rows: rows.map((c) {
                        return DataRow(
                          onSelectChanged: (_) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AdminClassDetailPage(clazz: c)),
                            );
                          },
                          cells: [
                            DataCell(Text('${c.id}')),
                            DataCell(Text(c.code)),
                            DataCell(Text(c.name)),
                            DataCell(Text('${c.subjectCode} - ${c.subjectName}')),
                            DataCell(Text(c.lecturer)),
                            DataCell(_statusChip(c.isActive)),
                            DataCell(
                              Wrap(
                                spacing: 8,
                                children: [
                                  IconButton(
                                    tooltip: 'Chi tiết',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AdminClassDetailPage(clazz: c),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.visibility_outlined, size: 20),
                                  ),
                                  IconButton(
                                    tooltip: 'Sửa',
                                    onPressed: () => _openEdit(c),
                                    icon: const Icon(Icons.edit_outlined, size: 20),
                                  ),
                                  IconButton(
                                    tooltip: c.isActive ? 'Khoá' : 'Mở',
                                    onPressed: () => _toggleActive(c),
                                    icon: Icon(
                                      c.isActive ? Icons.lock_outline : Icons.lock_open_outlined,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
