import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Backend base URL. Android emulators can't reach the host machine via
/// `localhost` — use `10.0.2.2` there instead. iOS simulator and desktop/web
/// builds can keep `localhost`.
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);

const _accessTokenKey = 'alef_access_token';
const _refreshTokenKey = 'alef_refresh_token';

class ApiException implements Exception {
  final int status;
  final String message;
  ApiException(this.status, this.message);

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  Future<String?> get accessToken async =>
      (await SharedPreferences.getInstance()).getString(_accessTokenKey);

  Future<String?> get refreshToken async =>
      (await SharedPreferences.getInstance()).getString(_refreshTokenKey);

  Future<void> setTokens({required String accessToken, required String refreshToken}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  String _errorMessage(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      final message = body['message'];
      if (message is List) return message.join(', ');
      if (message is String) return message;
    } catch (_) {
      // fall through to status text below
    }
    return 'Request failed (${res.statusCode})';
  }

  Future<bool> _tryRefresh() async {
    final refresh = await refreshToken;
    if (refresh == null) return false;
    final res = await http.post(
      Uri.parse('$kApiBaseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refresh}),
    );
    if (res.statusCode != 200) {
      await clearTokens();
      return false;
    }
    final data = jsonDecode(res.body);
    await setTokens(accessToken: data['accessToken'], refreshToken: data['refreshToken']);
    return true;
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool isRetry = false,
  }) async {
    final token = await accessToken;
    final uri = Uri.parse('$kApiBaseUrl$path');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    late http.Response res;
    switch (method) {
      case 'GET':
        res = await http.get(uri, headers: headers);
        break;
      case 'POST':
        res = await http.post(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
        break;
      case 'PATCH':
        res = await http.patch(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
        break;
      case 'DELETE':
        res = await http.delete(uri, headers: headers);
        break;
    }

    if (res.statusCode == 401 && !isRetry && await _tryRefresh()) {
      return _request(method, path, body: body, isRetry: true);
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(res.statusCode, _errorMessage(res));
    }

    if (res.body.isEmpty) return null;
    return jsonDecode(res.body);
  }

  Future<dynamic> get(String path) => _request('GET', path);
  Future<dynamic> post(String path, [Map<String, dynamic>? body]) => _request('POST', path, body: body);
  Future<dynamic> patch(String path, [Map<String, dynamic>? body]) => _request('PATCH', path, body: body);
  Future<dynamic> delete(String path) => _request('DELETE', path);
}
