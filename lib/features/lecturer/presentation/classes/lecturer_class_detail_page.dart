import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../grades/grade_entry_model.dart';
import 'lecturer_class_model.dart';

// ✅ new: attendance + announcements models
import '../attendance/attendance_models.dart';
import '../announcements/announcement_model.dart';

enum _StudentFilter { all, missingGrades, hasGrades }
enum _StudentSort { username, name, averageDesc, averageAsc }

class LecturerClassDetailPage extends StatefulWidget {
  final LecturerClass clazz;
  const LecturerClassDetailPage({super.key, required this.clazz});

  @override
  State<LecturerClassDetailPage> createState() => _LecturerClassDetailPageState();
}

class _LecturerClassDetailPageState extends State<LecturerClassDetailPage> {
  final _searchCtrl = TextEditingController();

  // ===== 1) sort/filter =====
  _StudentFilter _filter = _StudentFilter.all;
  _StudentSort _sort = _StudentSort.username;

  // ===== 2) save workflow =====
  bool _dirty = false;

  // ===== 4) weights =====
  // mock mặc định: 40% giữa kỳ, 60% cuối kỳ
  double _midtermWeight = 0.4;
  double _finalWeight = 0.6;

  // mock: danh sách SV trong lớp + điểm
  late List<GradeEntry> _entries;

  // ===== 5) attendance =====
  late AttendanceState _attendance;

  // ===== 7) announcements =====
  final List<Announcement> _announcements = [];

  @override
  void initState() {
    super.initState();

    _entries = [
      GradeEntry(studentUsername: 'sv01', studentName: 'Trần Thị B', midterm: 7.5, finalExam: 8.0),
      GradeEntry(studentUsername: 'sv02', studentName: 'Lê Văn C', midterm: 6.0, finalExam: 7.0),
      GradeEntry(studentUsername: 'sv03', studentName: 'Nguyễn Thị D'),
      GradeEntry(studentUsername: 'sv04', studentName: 'Phạm Văn E', midterm: 9.0),
    ];

    _attendance = AttendanceState.bootstrap(
      studentUsernames: _entries.map((e) => e.studentUsername).toList(),
      sessions: [
        DateTime.now().subtract(const Duration(days: 7)),
        DateTime.now().subtract(const Duration(days: 2)),
        DateTime.now(),
      ],
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ====== Helpers ======

  double? _avg(GradeEntry e) {
    // nếu cả 2 null -> null
    if (e.midterm == null && e.finalExam == null) return null;

    final m = e.midterm ?? 0;
    final f = e.finalExam ?? 0;
    return (m * _midtermWeight) + (f * _finalWeight);
  }

  bool _hasAnyGrade(GradeEntry e) => (e.midterm != null || e.finalExam != null);

  List<GradeEntry> get _filtered {
    final kw = _searchCtrl.text.trim().toLowerCase();

    List<GradeEntry> list = _entries.where((e) {
      final matchKw = kw.isEmpty ||
          e.studentUsername.toLowerCase().contains(kw) ||
          e.studentName.toLowerCase().contains(kw);

      if (!matchKw) return false;

      switch (_filter) {
        case _StudentFilter.all:
          return true;
        case _StudentFilter.missingGrades:
          return !_hasAnyGrade(e);
        case _StudentFilter.hasGrades:
          return _hasAnyGrade(e);
      }
    }).toList();

    list.sort((a, b) {
      switch (_sort) {
        case _StudentSort.username:
          return a.studentUsername.compareTo(b.studentUsername);
        case _StudentSort.name:
          return a.studentName.compareTo(b.studentName);
        case _StudentSort.averageDesc:
          final av = _avg(a) ?? -1;
          final bv = _avg(b) ?? -1;
          return bv.compareTo(av);
        case _StudentSort.averageAsc:
          final av = _avg(a) ?? 999;
          final bv = _avg(b) ?? 999;
          return av.compareTo(bv);
      }
    });

    return list;
  }

  Future<void> _editGrade(GradeEntry e) async {
    final result = await showDialog<_GradeDialogResult>(
      context: context,
      builder: (_) => _GradeDialog(
        username: e.studentUsername,
        name: e.studentName,
        initialMidterm: e.midterm,
        initialFinal: e.finalExam,
      ),
    );

    if (result == null) return;

    setState(() {
      e.midterm = result.midterm;
      e.finalExam = result.finalExam;
      _dirty = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã cập nhật điểm cho ${e.studentUsername}')),
    );
  }

  Future<void> _saveAll() async {
    // mock save: chỉ clear dirty
    setState(() => _dirty = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu bảng điểm / điểm danh / thông báo')),
    );
  }

  String _buildCsv() {
    final sb = StringBuffer();
    sb.writeln('username,fullName,midterm,final,average,attendancePercent');

    for (final e in _entries) {
      final m = e.midterm?.toStringAsFixed(1) ?? '';
      final f = e.finalExam?.toStringAsFixed(1) ?? '';
      final a = _avg(e)?.toStringAsFixed(1) ?? '';
      final att = (_attendance.percentFor(e.studentUsername) * 100).toStringAsFixed(0);

      // CSV: escape commas bằng quotes nếu cần (ở đây đơn giản)
      sb.writeln('${e.studentUsername},"${e.studentName}",$m,$f,$a,$att');
    }
    return sb.toString();
  }

  Future<void> _exportCsv() async {
    final csv = _buildCsv();

    // MVP: copy to clipboard (cross-platform), + show preview dialog
    await Clipboard.setData(ClipboardData(text: csv));
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Export CSV'),
        content: SizedBox(
          width: 720,
          child: SingleChildScrollView(
            child: SelectableText(
              csv,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đã copy clipboard'),
          ),
        ],
      ),
    );
  }

  Future<void> _createAnnouncement() async {
    final result = await showDialog<Announcement>(
      context: context,
      builder: (_) => const _AnnouncementDialog(),
    );

    if (result == null) return;

    setState(() {
      _announcements.insert(0, result);
      _dirty = true;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã tạo thông báo')),
    );
  }

  Future<void> _editAttendanceSession(DateTime session) async {
    // mở dialog tick present/absent theo buổi
    final usernames = _entries.map((e) => e.studentUsername).toList();
    final nameMap = {for (final e in _entries) e.studentUsername: e.studentName};

    final result = await showDialog<Set<String>>(
      context: context,
      builder: (_) => _AttendanceDialog(
        session: session,
        allStudents: usernames,
        presentSet: _attendance.presentSet(session),
        nameMap: nameMap,
      ),
    );

    if (result == null) return;

    setState(() {
      _attendance.setPresentForSession(session, result);
      _dirty = true;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã cập nhật điểm danh.')),
    );
  }

  // ====== UI ======

  @override
  Widget build(BuildContext context) {
    final c = widget.clazz;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Lớp: ${c.code}'),
        actions: [
          // (2) Save
          TextButton(
            onPressed: _dirty ? _saveAll : null,
            child: Text(_dirty ? 'Lưu thay đổi' : 'Đã lưu'),
          ),
          const SizedBox(width: 8),
          // (6) Export CSV
          TextButton(
            onPressed: _exportCsv,
            child: const Text('Export CSV'),
          ),
          const SizedBox(width: 8),
          // (7) Announcement create
          TextButton(
            onPressed: _createAnnouncement,
            child: const Text('Tạo thông báo'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text('${c.subjectCode} - ${c.subjectName}'),
              const SizedBox(height: 12),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: cs.outlineVariant.withOpacity(0.6)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 460,
                        child: TextField(
                          controller: _searchCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Tìm sinh viên (username / tên)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      SizedBox(
                        width: 220,
                        child: DropdownButtonFormField<_StudentFilter>(
                          value: _filter,
                          decoration: const InputDecoration(
                            labelText: 'Lọc',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: _StudentFilter.all,
                              child: Text('Tất cả'),
                            ),
                            DropdownMenuItem(
                              value: _StudentFilter.missingGrades,
                              child: Text('Chưa có điểm'),
                            ),
                            DropdownMenuItem(
                              value: _StudentFilter.hasGrades,
                              child: Text('Đã có điểm'),
                            ),
                          ],
                          onChanged: (v) => setState(() => _filter = v ?? _StudentFilter.all),
                        ),
                      ),
                      SizedBox(
                        width: 240,
                        child: DropdownButtonFormField<_StudentSort>(
                          value: _sort,
                          decoration: const InputDecoration(
                            labelText: 'Sắp xếp',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: _StudentSort.username,
                              child: Text('Theo username'),
                            ),
                            DropdownMenuItem(
                              value: _StudentSort.name,
                              child: Text('Theo họ tên'),
                            ),
                            DropdownMenuItem(
                              value: _StudentSort.averageDesc,
                              child: Text('Điểm TB (cao → thấp)'),
                            ),
                            DropdownMenuItem(
                              value: _StudentSort.averageAsc,
                              child: Text('Điểm TB (thấp → cao)'),
                            ),
                          ],
                          onChanged: (v) => setState(() => _sort = v ?? _StudentSort.username),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: 'Bảng điểm'),
                  Tab(text: 'Điểm danh'),
                  Tab(text: 'Thông báo'),
                ],
              ),
              const SizedBox(height: 12),

              Expanded(
                child: TabBarView(
                  children: [
                    _buildGrades(cs),
                    _buildAttendance(cs),
                    _buildAnnouncements(cs),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(ColorScheme cs, Widget child) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }

  // ===== TAB 1: GRADES =====
  Widget _buildGrades(ColorScheme cs) {
    final rows = _filtered;

    return Column(
      children: [
        // (4) weights config (nhẹ, đúng nhu cầu)
        _card(
          cs,
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 260,
                child: Text('Tỉ trọng: Giữa kỳ ${(100 * _midtermWeight).round()}% • Cuối kỳ ${(100 * _finalWeight).round()}%'),
              ),
              SizedBox(
                width: 260,
                child: Slider(
                  value: _midtermWeight,
                  min: 0,
                  max: 1,
                  divisions: 10,
                  label: 'Giữa kỳ ${(100 * _midtermWeight).round()}%',
                  onChanged: (v) {
                    setState(() {
                      _midtermWeight = v;
                      _finalWeight = 1 - v;
                      _dirty = true;
                    });
                  },
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _midtermWeight = 0.4;
                    _finalWeight = 0.6;
                    _dirty = true;
                  });
                },
                child: const Text('Reset 40/60'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Expanded(
          child: _card(
            cs,
            rows.isEmpty
                ? const Center(child: Text('Không có sinh viên'))
                : ListView.separated(
                    itemCount: rows.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final e = rows[i];
                      final avg = _avg(e);
                      final att = (_attendance.percentFor(e.studentUsername) * 100).toStringAsFixed(0);

                      return ListTile(
                        title: Text('${e.studentUsername} - ${e.studentName}'),
                        subtitle: Text(
                          'Giữa kỳ: ${e.midterm?.toStringAsFixed(1) ?? '-'} • '
                          'Cuối kỳ: ${e.finalExam?.toStringAsFixed(1) ?? '-'} • '
                          'TB: ${avg?.toStringAsFixed(1) ?? '-'} • '
                          'CC: $att%',
                        ),
                        trailing: TextButton(
                          onPressed: () => _editGrade(e),
                          child: const Text('Nhập điểm'),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  // ===== TAB 2: ATTENDANCE =====
  Widget _buildAttendance(ColorScheme cs) {
    final sessions = _attendance.sessions;

    return Column(
      children: [
        _card(
          cs,
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Danh sách buổi học. Bấm vào 1 buổi để điểm danh.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _attendance.addSession(DateTime.now());
                    _dirty = true;
                  });
                },
                child: const Text('Thêm buổi hôm nay'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _card(
            cs,
            sessions.isEmpty
                ? const Center(child: Text('Chưa có buổi học'))
                : ListView.separated(
                    itemCount: sessions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final s = sessions[i];
                      final presentCount = _attendance.presentSet(s).length;
                      final total = _entries.length;

                      return ListTile(
                        title: Text('Buổi ${i + 1} • ${_fmtDate(s)}'),
                        subtitle: Text('Có mặt: $presentCount / $total'),
                        trailing: TextButton(
                          onPressed: () => _editAttendanceSession(s),
                          child: const Text('Điểm danh'),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  // ===== TAB 3: ANNOUNCEMENTS =====
  Widget _buildAnnouncements(ColorScheme cs) {
    return Column(
      children: [
        _card(
          cs,
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Thông báo cho lớp. Sau này student sẽ đọc từ backend.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: _createAnnouncement,
                child: const Text('Tạo thông báo'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _card(
            cs,
            _announcements.isEmpty
                ? const Center(child: Text('Chưa có thông báo'))
                : ListView.separated(
                    itemCount: _announcements.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final a = _announcements[i];
                      return ListTile(
                        title: Text(a.title),
                        subtitle: Text('${_fmtDateTime(a.createdAt)}\n${a.content}'),
                        isThreeLine: true,
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return '$dd/$mm/$yy';
  }

  String _fmtDateTime(DateTime d) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '${_fmtDate(d)} $hh:$mi';
  }
}

// ===== Dialog nhập điểm (mock) =====

class _GradeDialogResult {
  final double? midterm;
  final double? finalExam;
  _GradeDialogResult({required this.midterm, required this.finalExam});
}

class _GradeDialog extends StatefulWidget {
  final String username;
  final String name;
  final double? initialMidterm;
  final double? initialFinal;

  const _GradeDialog({
    required this.username,
    required this.name,
    required this.initialMidterm,
    required this.initialFinal,
  });

  @override
  State<_GradeDialog> createState() => _GradeDialogState();
}

class _GradeDialogState extends State<_GradeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _midtermCtrl;
  late final TextEditingController _finalCtrl;

  @override
  void initState() {
    super.initState();
    _midtermCtrl = TextEditingController(text: widget.initialMidterm?.toString() ?? '');
    _finalCtrl = TextEditingController(text: widget.initialFinal?.toString() ?? '');
  }

  @override
  void dispose() {
    _midtermCtrl.dispose();
    _finalCtrl.dispose();
    super.dispose();
  }

  double? _parseOrNull(String s) {
    final t = s.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  String? _validateScore(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final x = double.tryParse(v.trim());
    if (x == null) return 'Điểm không hợp lệ';
    if (x < 0 || x > 10) return 'Điểm phải 0 - 10';
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      _GradeDialogResult(
        midterm: _parseOrNull(_midtermCtrl.text),
        finalExam: _parseOrNull(_finalCtrl.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Nhập điểm: ${widget.username}'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(alignment: Alignment.centerLeft, child: Text(widget.name)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _midtermCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Điểm giữa kỳ (0-10)',
                  border: OutlineInputBorder(),
                ),
                validator: _validateScore,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _finalCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Điểm cuối kỳ (0-10)',
                  border: OutlineInputBorder(),
                ),
                validator: _validateScore,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
        FilledButton(onPressed: _save, child: const Text('Lưu')),
      ],
    );
  }
}

// ===== Attendance dialog =====

class _AttendanceDialog extends StatefulWidget {
  final DateTime session;
  final List<String> allStudents;
  final Set<String> presentSet;
  final Map<String, String> nameMap;

  const _AttendanceDialog({
    required this.session,
    required this.allStudents,
    required this.presentSet,
    required this.nameMap,
  });

  @override
  State<_AttendanceDialog> createState() => _AttendanceDialogState();
}

class _AttendanceDialogState extends State<_AttendanceDialog> {
  late Set<String> _present;

  @override
  void initState() {
    super.initState();
    _present = {...widget.presentSet};
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Điểm danh'),
      content: SizedBox(
        width: 520,
        height: 520,
        child: ListView.builder(
          itemCount: widget.allStudents.length,
          itemBuilder: (context, i) {
            final u = widget.allStudents[i];
            final name = widget.nameMap[u] ?? '';
            final checked = _present.contains(u);

            return CheckboxListTile(
              value: checked,
              onChanged: (v) {
                setState(() {
                  if (v == true) {
                    _present.add(u);
                  } else {
                    _present.remove(u);
                  }
                });
              },
              title: Text('$u - $name'),
              controlAffinity: ListTileControlAffinity.leading,
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
        FilledButton(
          onPressed: () => Navigator.pop(context, _present),
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}

// ===== Announcement dialog =====

class _AnnouncementDialog extends StatefulWidget {
  const _AnnouncementDialog();

  @override
  State<_AnnouncementDialog> createState() => _AnnouncementDialogState();
}

class _AnnouncementDialogState extends State<_AnnouncementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      Announcement(
        title: _titleCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tạo thông báo'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập tiêu đề' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contentCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập nội dung' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
        FilledButton(onPressed: _submit, child: const Text('Đăng')),
      ],
    );
  }
}
