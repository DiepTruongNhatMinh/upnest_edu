import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/centered_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../domain/user_role.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  UserRole _selectedRole = UserRole.student;

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

    // TODO: sau này bạn thay bằng gọi API / Firebase auth
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() => _isLoading = false);

    String route;
    switch (_selectedRole) {
      case UserRole.admin:
        route = UpnestRoutes.adminHome;
        break;
      case UserRole.lecturer:
        route = UpnestRoutes.lecturerHome;
        break;
      case UserRole.student:
        route = UpnestRoutes.studentHome;
        break;
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, route);
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
                    // Logo + Title
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
                    // Card Login
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
                            const SizedBox(height: 12),
                            DropdownButtonFormField<UserRole>(
                              value: _selectedRole,
                              decoration: const InputDecoration(
                                labelText: 'Vai trò',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                              items: UserRole.values
                                  .map(
                                    (role) => DropdownMenuItem(
                                      value: role,
                                      child: Text(role.label),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (role) {
                                if (role != null) {
                                  setState(() {
                                    _selectedRole = role;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 24),
                            PrimaryButton(
                              text: 'Đăng nhập',
                              isLoading: _isLoading,
                              onPressed: _onLogin,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Demo: hiện tại chỉ check form, không kiểm tra tài khoản thực.',
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
