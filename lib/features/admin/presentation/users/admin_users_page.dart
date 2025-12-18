import 'package:flutter/material.dart';
import 'admin_user_model.dart';
import 'admin_user_form_page.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final _keywordCtrl = TextEditingController();

  String _roleFilter = 'ALL';
  String _activeFilter = 'ALL';

  // ===== MOCK DATA =====
  List<AdminUser> _users = [
    const AdminUser(
      id: 1,
      username: 'admin',
      fullName: 'Quản trị hệ thống',
      email: 'admin@upnest.edu',
      roleCode: 'ADMIN',
      isActive: true,
    ),
    const AdminUser(
      id: 2,
      username: 'gv01',
      fullName: 'Nguyễn Văn A',
      email: 'gv01@upnest.edu',
      roleCode: 'LECTURER',
      isActive: true,
    ),
    const AdminUser(
      id: 3,
      username: 'gv02',
      fullName: 'Trần Văn K',
      email: 'gv02@upnest.edu',
      roleCode: 'LECTURER',
      isActive: true,
    ),
    const AdminUser(
      id: 4,
      username: 'sv01',
      fullName: 'Trần Thị B',
      email: 'sv01@upnest.edu',
      roleCode: 'STUDENT',
      isActive: true,
    ),
    const AdminUser(
      id: 5,
      username: 'sv02',
      fullName: 'Lê Văn C',
      email: 'sv02@upnest.edu',
      roleCode: 'STUDENT',
      isActive: false,
    ),
    const AdminUser(
      id: 6,
      username: 'sv03',
      fullName: 'Phạm Minh D',
      email: 'sv03@upnest.edu',
      roleCode: 'STUDENT',
      isActive: true,
    ),
  ];

  @override
  void dispose() {
    _keywordCtrl.dispose();
    super.dispose();
  }

  List<AdminUser> get _filtered {
    final kw = _keywordCtrl.text.trim().toLowerCase();

    return _users.where((u) {
      final matchKw = kw.isEmpty ||
          u.username.toLowerCase().contains(kw) ||
          u.fullName.toLowerCase().contains(kw) ||
          u.email.toLowerCase().contains(kw);

      final matchRole = _roleFilter == 'ALL' || u.roleCode == _roleFilter;

      final matchActive = _activeFilter == 'ALL' ||
          (_activeFilter == 'ACTIVE' && u.isActive) ||
          (_activeFilter == 'INACTIVE' && !u.isActive);

      return matchKw && matchRole && matchActive;
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

  void _toggleActive(AdminUser u) {
    setState(() {
      _users = _users
          .map((x) => x.id == u.id ? x.copyWith(isActive: !x.isActive) : x)
          .toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(u.isActive ? 'Đã khoá user' : 'Đã kích hoạt user')),
    );
  }

  Future<void> _openCreate() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AdminUserFormPage()),
    );

    if (ok == true) {
      setState(() {
        final nextId =
            (_users.map((e) => e.id).fold<int>(0, (a, b) => a > b ? a : b)) + 1;
        _users = [
          ..._users,
          AdminUser(
            id: nextId,
            username: 'new$nextId',
            fullName: 'User mới $nextId',
            email: 'new$nextId@upnest.edu',
            roleCode: 'STUDENT',
            isActive: true,
          ),
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final rows = _filtered;

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
                  labelText: 'Tìm username / tên / email',
                  hintText: 'Ví dụ: sv01, Nguyễn, @upnest.edu',
                  border: OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String>(
                value: _roleFilter,
                decoration: const InputDecoration(
                  labelText: 'Vai trò',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('Tất cả')),
                  DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                  DropdownMenuItem(value: 'LECTURER', child: Text('LECTURER')),
                  DropdownMenuItem(value: 'STUDENT', child: Text('STUDENT')),
                ],
                onChanged: (v) => setState(() => _roleFilter = v ?? 'ALL'),
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
                label: const Text('Thêm user'),
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
                          Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Username')),
                        DataColumn(label: Text('Họ tên')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Role')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Hành động')),
                      ],
                      rows: rows.map((u) {
                        return DataRow(
                          cells: [
                            DataCell(Text('${u.id}')),
                            DataCell(Text(u.username)),
                            DataCell(Text(u.fullName)),
                            DataCell(Text(u.email)),
                            DataCell(Text(u.roleCode)),
                            DataCell(_statusChip(u.isActive)),
                            DataCell(
                              TextButton(
                                onPressed: () => _toggleActive(u),
                                child: Text(u.isActive ? 'Khoá' : 'Mở'),
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
