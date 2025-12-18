import 'package:flutter/material.dart';
import 'admin_subject_model.dart';
import 'admin_subject_form_page.dart';

class AdminSubjectsPage extends StatefulWidget {
  const AdminSubjectsPage({super.key});

  @override
  State<AdminSubjectsPage> createState() => _AdminSubjectsPageState();
}

class _AdminSubjectsPageState extends State<AdminSubjectsPage> {
  final _keywordCtrl = TextEditingController();
  String _activeFilter = 'ALL';

  // ✅ mock data
  List<AdminSubject> _subjects = const [
    AdminSubject(id: 1, code: 'MATH', name: 'Toán', isActive: true),
    AdminSubject(id: 2, code: 'PHY', name: 'Vật lý', isActive: true),
    AdminSubject(id: 3, code: 'ENG', name: 'Tiếng Anh', isActive: false),
    AdminSubject(id: 4, code: 'CHEM', name: 'Hóa học', isActive: true),
    AdminSubject(id: 5, code: 'BIO', name: 'Sinh học', isActive: true),
  ];

  @override
  void dispose() {
    _keywordCtrl.dispose();
    super.dispose();
  }

  List<AdminSubject> get _filtered {
    final kw = _keywordCtrl.text.trim().toLowerCase();
    return _subjects.where((s) {
      final matchKw = kw.isEmpty ||
          s.code.toLowerCase().contains(kw) ||
          s.name.toLowerCase().contains(kw);

      final matchActive = _activeFilter == 'ALL' ||
          (_activeFilter == 'ACTIVE' && s.isActive) ||
          (_activeFilter == 'INACTIVE' && !s.isActive);

      return matchKw && matchActive;
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

  void _toggleActive(AdminSubject s) {
    setState(() {
      _subjects = _subjects
          .map((x) => x.id == s.id ? x.copyWith(isActive: !x.isActive) : x)
          .toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.isActive ? 'Đã khoá môn' : 'Đã kích hoạt môn')),
    );
  }

  Future<void> _openCreate() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AdminSubjectFormPage()),
    );

    if (ok == true) {
      setState(() {
        final maxId = _subjects.map((e) => e.id).fold<int>(0, (a, b) => a > b ? a : b);
        final nextId = maxId + 1;
        _subjects = [
          ..._subjects,
          AdminSubject(
            id: nextId,
            code: 'NEW$nextId',
            name: 'Môn mới $nextId',
            isActive: true,
          ),
        ];
      });
    }
  }

  Future<void> _openEdit(AdminSubject s) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AdminSubjectFormPage(subject: s)),
    );

    if (ok == true) {
      setState(() {
        _subjects = _subjects
            .map((x) => x.id == s.id ? x.copyWith(name: '${x.name} (edited)') : x)
            .toList();
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
                  labelText: 'Tìm mã môn / tên môn',
                  hintText: 'Ví dụ: MATH, Toán, ENG',
                  border: OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (_) => setState(() {}),
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
                label: const Text('Thêm môn học'),
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
                        DataColumn(label: Text('Mã môn')),
                        DataColumn(label: Text('Tên môn')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Hành động')),
                      ],
                      rows: rows.map((s) {
                        return DataRow(
                          onSelectChanged: (_) => _openEdit(s),
                          cells: [
                            DataCell(Text('${s.id}')),
                            DataCell(Text(s.code)),
                            DataCell(Text(s.name)),
                            DataCell(_statusChip(s.isActive)),
                            DataCell(
                              Wrap(
                                spacing: 8,
                                children: [
                                  IconButton(
                                    tooltip: 'Sửa',
                                    onPressed: () => _openEdit(s),
                                    icon: const Icon(Icons.edit_outlined, size: 20),
                                  ),
                                  IconButton(
                                    tooltip: s.isActive ? 'Khoá' : 'Mở',
                                    onPressed: () => _toggleActive(s),
                                    icon: Icon(
                                      s.isActive ? Icons.lock_outline : Icons.lock_open_outlined,
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
