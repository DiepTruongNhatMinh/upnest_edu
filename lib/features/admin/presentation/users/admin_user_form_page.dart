import 'package:flutter/material.dart';
import 'admin_user_model.dart';

class AdminUserFormPage extends StatefulWidget {
  final AdminUser? user;
  const AdminUserFormPage({super.key, this.user});

  @override
  State<AdminUserFormPage> createState() => _AdminUserFormPageState();
}

class _AdminUserFormPageState extends State<AdminUserFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _username = TextEditingController();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  String _role = 'STUDENT';

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    if (u != null) {
      _username.text = u.username;
      _fullName.text = u.fullName;
      _email.text = u.email;
      _role = u.roleCode;
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, true); // ✅ mock: báo “save ok”
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Sửa người dùng' : 'Thêm người dùng'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _username,
                enabled: !isEdit, // edit không cho sửa username (chuẩn)
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập username' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fullName,
                decoration: const InputDecoration(labelText: 'Họ tên'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập họ tên' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Vai trò'),
                items: const [
                  DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                  DropdownMenuItem(value: 'LECTURER', child: Text('LECTURER')),
                  DropdownMenuItem(value: 'STUDENT', child: Text('STUDENT')),
                ],
                onChanged: (v) => setState(() => _role = v ?? 'STUDENT'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                decoration: InputDecoration(
                  labelText: isEdit ? 'Mật khẩu mới (nếu đổi)' : 'Mật khẩu',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
