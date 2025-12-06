import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/centered_card.dart';
import '../../../core/widgets/primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // ⚠️ Nếu chạy Flutter web trên cùng máy backend:
      final uri = Uri.parse('http://localhost:5000/api/auth/login');

      // Nếu sau này chạy Android emulator:
      // final uri = Uri.parse('http://10.0.2.2:5000/api/auth/login');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameCtrl.text.trim(),
          'password': _passwordCtrl.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final roleCode = data['roleCode'] as String? ?? '';
        // final token = data['token'] as String; // TODO: lưu lại nếu cần

        String route;
        switch (roleCode.toUpperCase()) {
          case 'ADMIN':
            route = UpnestRoutes.adminHome;
            break;
          case 'LECTURER':
            route = UpnestRoutes.lecturerHome;
            break;
          case 'STUDENT':
          default:
            route = UpnestRoutes.studentHome;
            break;
        }

        Navigator.pushReplacementNamed(context, route);
      } else {
        String message = 'Đăng nhập thất bại, vui lòng kiểm tra lại.';

        try {
          final body = jsonDecode(response.body);
          if (body is Map && body['message'] != null) {
            message = body['message'].toString();
          }
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi kết nối: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.primaryContainer.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'UpNest Edu',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nền tảng quản lý giáo dục đa vai trò',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    CenteredCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Đăng nhập',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _usernameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Tài khoản',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (v) =>
                                  Validators.requiredField(v, 'Vui lòng nhập tài khoản'),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Mật khẩu',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              validator: (v) =>
                                  Validators.requiredField(v, 'Vui lòng nhập mật khẩu'),
                            ),
                            const SizedBox(height: 24),
                            PrimaryButton(
                              text: 'Đăng nhập',
                              isLoading: _isLoading,
                              onPressed: _onLogin,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tài khoản demo: admin/admin123, gv01/gv123, sv01/sv123 (đăng nhập kiểm tra từ SQL + Node API).',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
