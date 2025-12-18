import 'package:flutter/material.dart';
import 'admin_class_model.dart';

class AdminClassDetailPage extends StatefulWidget {
  final AdminClass clazz;
  const AdminClassDetailPage({super.key, required this.clazz});

  @override
  State<AdminClassDetailPage> createState() => _AdminClassDetailPageState();
}

class _AdminClassDetailPageState extends State<AdminClassDetailPage> {
  final _lecturerSearch = TextEditingController();
  final _studentSearch = TextEditingController();

  final List<Map<String, String>> _lecturers = const [
    {'username': 'gv01', 'name': 'Nguyễn Văn A'},
    {'username': 'gv02', 'name': 'Trần Văn B'},
    {'username': 'gv03', 'name': 'Lê Thị C'},
  ];

  final List<Map<String, String>> _students = const [
    {'username': 'sv01', 'name': 'Trần Thị B'},
    {'username': 'sv02', 'name': 'Lê Văn C'},
    {'username': 'sv03', 'name': 'Nguyễn Thị D'},
    {'username': 'sv04', 'name': 'Phạm Văn E'},
  ];

  String? _assignedLecturer;
  final Set<String> _enrolledStudents = {'sv01', 'sv02'};

  @override
  void initState() {
    super.initState();
    _assignedLecturer = widget.clazz.lecturer;
  }

  @override
  void dispose() {
    _lecturerSearch.dispose();
    _studentSearch.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filteredLecturers {
    final kw = _lecturerSearch.text.trim().toLowerCase();
    if (kw.isEmpty) return _lecturers;
    return _lecturers.where((l) {
      return (l['username'] ?? '').toLowerCase().contains(kw) ||
          (l['name'] ?? '').toLowerCase().contains(kw);
    }).toList();
  }

  List<Map<String, String>> get _filteredStudents {
    final kw = _studentSearch.text.trim().toLowerCase();
    if (kw.isEmpty) return _students;
    return _students.where((s) {
      return (s['username'] ?? '').toLowerCase().contains(kw) ||
          (s['name'] ?? '').toLowerCase().contains(kw);
    }).toList();
  }

  Widget _sectionCard({required Widget child}) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.clazz;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết lớp: ${c.code}'),
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
              Text(
                '${c.subjectCode} - ${c.subjectName}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: 'Thông tin'),
                  Tab(text: 'Gán giảng viên'),
                  Tab(text: 'Gán sinh viên'),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildInfo(c),
                    _buildAssignLecturer(),
                    _buildEnrollStudents(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(AdminClass c) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Mã lớp', c.code),
          _infoRow('Tên lớp', c.name),
          _infoRow('Môn học', '${c.subjectCode} - ${c.subjectName}'),
          _infoRow('Giảng viên', _assignedLecturer ?? '(chưa gán)'),
          _infoRow('Số sinh viên', '${_enrolledStudents.length}'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildAssignLecturer() {
    final list = _filteredLecturers;

    return Column(
      children: [
        _sectionCard(
          child: TextField(
            controller: _lecturerSearch,
            decoration: const InputDecoration(
              labelText: 'Tìm giảng viên (username / tên)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _sectionCard(
            child: ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final l = list[i];
                final username = l['username'] ?? '';
                final name = l['name'] ?? '';
                final selected = username == _assignedLecturer;

                return ListTile(
                  title: Text('$username - $name'),
                  trailing: TextButton(
                    onPressed: () {
                      setState(() => _assignedLecturer = username);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã gán giảng viên: $username')),
                      );
                    },
                    child: Text(selected ? 'Đang gán' : 'Gán'),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnrollStudents() {
    final list = _filteredStudents;

    return Column(
      children: [
        _sectionCard(
          child: TextField(
            controller: _studentSearch,
            decoration: const InputDecoration(
              labelText: 'Tìm sinh viên (username / tên)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _sectionCard(
            child: ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final s = list[i];
                final username = s['username'] ?? '';
                final name = s['name'] ?? '';
                final enrolled = _enrolledStudents.contains(username);

                return ListTile(
                  title: Text('$username - $name'),
                  trailing: TextButton(
                    onPressed: () {
                      setState(() {
                        if (enrolled) {
                          _enrolledStudents.remove(username);
                        } else {
                          _enrolledStudents.add(username);
                        }
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            enrolled
                                ? 'Đã huỷ gán sinh viên: $username'
                                : 'Đã gán sinh viên: $username',
                          ),
                        ),
                      );
                    },
                    child: Text(enrolled ? 'Bỏ' : 'Gán'),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
