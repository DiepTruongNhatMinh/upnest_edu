import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/centered_card.dart';
import '../../../core/widgets/primary_button.dart';

import 'package:upnest_edu/features/auth/data/auth_service.dart';

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

  String _baseUrl() {
    if (kIsWeb) return 'http://localhost:5000';
    // Android emulator:
    // return 'http://10.0.2.2:5000';
    // Android thật (đổi IP LAN PC chạy Node):
    // return 'http://192.168.1.10:5000';
    return 'http://localhost:5000';
  }

  int _toInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

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
      final uri = Uri.parse('${_baseUrl()}/api/auth/login');

      final response = await http.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameCtrl.text.trim(),
          'password': _passwordCtrl.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        final token = (data['token'] ?? '').toString();
        final roleCode = (data['roleCode'] ?? '').toString();
        final userId = _toInt(data['userId']);
        final fullName = (data['fullName'] ?? '').toString();

        if (token.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backend trả về thiếu token.')),
          );
          return;
        }

        await AuthService.saveLogin(
          token: token,
          roleCode: roleCode,
          userId: userId,
          fullName: fullName,
        );

        final upper = roleCode.toUpperCase();
        final route = switch (upper) {
          'ADMIN' => UpnestRoutes.adminHome,
          'LECTURER' => UpnestRoutes.lecturerHome,
          _ => UpnestRoutes.studentHome,
        };

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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primary.withOpacity(0.10),
              cs.primaryContainer.withOpacity(0.30),
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
                            color: cs.primary,
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Đăng nhập',
                                style: Theme.of(context).textTheme.titleLarge),
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
                              'Demo: admin/admin123, gv01/gv123, sv01/sv123',
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
