import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl = 'https://gohosim.gohotravel.workers.dev';
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  // ── Token management ──────────────────────────────────────────
  static Future<String?> getToken() => _storage.read(key: _tokenKey);
  static Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);
  static Future<void> clearToken() => _storage.delete(key: _tokenKey);

  // ── Base request ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> get(String path, {bool auth = false}) async {
    final headers = await _headers(auth);
    final res = await http.get(Uri.parse('$baseUrl$path'), headers: headers);
    return _parse(res);
  }

  static Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body,
      {bool auth = false}) async {
    final headers = await _headers(auth);
    final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _parse(res);
  }

  static Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body,
      {bool auth = false}) async {
    final headers = await _headers(auth);
    final res = await http.patch(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _parse(res);
  }

  static Future<Map<String, String>> _headers(bool auth) async {
    final h = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  static Map<String, dynamic> _parse(http.Response res) {
    try {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return data;
    } catch (_) {
      return {'ok': false, 'error': 'Response tidak valid (${res.statusCode})'};
    }
  }
}
