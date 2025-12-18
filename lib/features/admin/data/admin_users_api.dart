import 'dart:convert';

import 'package:upnest_edu/core/network/api_client.dart';
import 'package:upnest_edu/features/admin/presentation/users/admin_user_model.dart';

class AdminUsersApi {
  final ApiClient _client;

  AdminUsersApi({ApiClient? client}) : _client = client ?? ApiClient();

  Future<List<AdminUser>> fetchUsers({
    String kw = '',
    String role = 'ALL',
    String active = 'ALL',
  }) async {
    final qKw = Uri.encodeQueryComponent(kw.trim());

    final res = await _client.get(
      '/api/admin/users?kw=$qKw&role=$role&active=$active',
      auth: true,
    );

    if (res.statusCode != 200) {
      // backend hay trả {"message":"Missing token"} hoặc message khác
      throw Exception('Load users failed (${res.statusCode}): ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! List) {
      throw Exception('Invalid response: expected List but got ${decoded.runtimeType}');
    }

    return decoded.map<AdminUser>((e) {
      final m = e as Map<String, dynamic>;

      final id = (m['id'] as num?)?.toInt() ?? 0;
      final username = (m['username'] ?? '').toString();
      final fullName = (m['full_name'] ?? '').toString();
      final email = (m['email'] ?? '').toString();
      final roleCode = (m['role_code'] ?? '').toString();

      final rawActive = m['is_active'];
      final isActive = rawActive == true || rawActive == 1;

      return AdminUser(
        id: id,
        username: username,
        fullName: fullName,
        email: email,
        roleCode: roleCode,
        isActive: isActive,
      );
    }).toList();
  }

  Future<void> setActive(int id, bool isActive) async {
    final res = await _client.patch(
      '/api/admin/users/$id/active',
      {'isActive': isActive},
      auth: true,
    );

    if (res.statusCode != 200) {
      throw Exception('Update active failed (${res.statusCode}): ${res.body}');
    }
  }
}
