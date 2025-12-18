import 'package:flutter/material.dart';
import 'admin_subject_model.dart';

class AdminSubjectFormPage extends StatefulWidget {
  final AdminSubject? subject;
  const AdminSubjectFormPage({super.key, this.subject});

  @override
  State<AdminSubjectFormPage> createState() => _AdminSubjectFormPageState();
}

class _AdminSubjectFormPageState extends State<AdminSubjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _name = TextEditingController();

  @override
  void initState() {
    super.initState();
    final s = widget.subject;
    if (s != null) {
      _code.text = s.code;
      _name.text = s.name;
    }
  }

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.subject != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Sửa môn học' : 'Thêm môn học')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _code,
                enabled: !isEdit,
                decoration: const InputDecoration(
                  labelText: 'Mã môn',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập mã môn' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Tên môn',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập tên môn' : null,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _save,
                child: const Text('Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
