import 'package:flutter/material.dart';
import 'admin_class_model.dart';

class AdminClassFormPage extends StatefulWidget {
  final List<Map<String, String>> subjects;
  final AdminClass? initial;

  const AdminClassFormPage({
    super.key,
    required this.subjects,
    this.initial,
  });

  @override
  State<AdminClassFormPage> createState() => _AdminClassFormPageState();
}

class _AdminClassFormPageState extends State<AdminClassFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _name = TextEditingController();
  final _lecturer = TextEditingController();

  String _subjectCode = 'MATH';

  @override
  void initState() {
    super.initState();

    final c = widget.initial;
    if (c != null) {
      _code.text = c.code;
      _name.text = c.name;
      _lecturer.text = c.lecturer;
      _subjectCode = c.subjectCode;
    } else {
      if (widget.subjects.isNotEmpty) {
        _subjectCode = widget.subjects.first['code']!;
      }
    }
  }

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _lecturer.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Sửa lớp học' : 'Thêm lớp học')),
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
                  labelText: 'Mã lớp',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập mã lớp' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Tên lớp',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập tên lớp' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _subjectCode,
                decoration: const InputDecoration(
                  labelText: 'Môn học',
                  border: OutlineInputBorder(),
                ),
                items: widget.subjects
                    .map((s) => DropdownMenuItem(
                          value: s['code'],
                          child: Text('${s['code']} - ${s['name']}'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _subjectCode = v ?? _subjectCode),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lecturer,
                decoration: const InputDecoration(
                  labelText: 'Giảng viên (username)',
                  hintText: 'Ví dụ: gv01',
                  border: OutlineInputBorder(),
                ),
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
