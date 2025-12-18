import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:upnest_edu/features/auth/data/auth_service.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? _defaultBaseUrl();

  static String _defaultBaseUrl() {
    // Web chạy trên Chrome: localhost OK
    if (kIsWeb) return 'http://localhost:5000';

    // Android emulator (nếu bạn dùng emulator thì bật dòng này)
    // return 'http://10.0.2.2:5000';

    // Android thật: đổi sang IP LAN của máy chạy Node
    // return 'http://192.168.1.10:5000';

    // Desktop (Windows/macOS): localhost OK
    return 'http://localhost:5000';
  }

  Uri _uri(String path) {
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$p');
  }

  Future<Map<String, String>> _headers({
    Map<String, String>? extra,
    bool auth = true,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?extra,
    };

    if (auth) {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        // ✅ debug dễ: bạn sẽ thấy rõ vì sao bị Missing token
        // (Không throw ở đây để tránh crash UI, backend sẽ trả 401)
        return headers;
      }
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
    bool auth = true,
  }) async {
    final h = await _headers(extra: headers, auth: auth);
    return http.get(_uri(path), headers: h);
  }

  Future<http.Response> post(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    bool auth = true,
  }) async {
    final h = await _headers(extra: headers, auth: auth);
    return http.post(_uri(path), headers: h, body: jsonEncode(body));
  }

  Future<http.Response> patch(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    bool auth = true,
  }) async {
    final h = await _headers(extra: headers, auth: auth);
    return http.patch(_uri(path), headers: h, body: jsonEncode(body));
  }

  Future<http.Response> delete(
    String path, {
    Map<String, String>? headers,
    bool auth = true,
  }) async {
    final h = await _headers(extra: headers, auth: auth);
    return http.delete(_uri(path), headers: h);
  }
}
