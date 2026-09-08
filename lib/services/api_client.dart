import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Production is the safe default. Local development can override it with
/// `--dart-define=API_BASE_URL=http://10.0.2.2:3000` on Android emulators.
const String _configuredApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://api.aliffuture.com',
);
String get kApiBaseUrl => _configuredApiBaseUrl.endsWith('/')
    ? _configuredApiBaseUrl.substring(0, _configuredApiBaseUrl.length - 1)
    : _configuredApiBaseUrl;

const _accessTokenKey = 'alef_access_token';
const _refreshTokenKey = 'alef_refresh_token';
const _requestTimeout = Duration(seconds: 20);

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

  static const _storage = FlutterSecureStorage();
  Future<bool>? _refreshInFlight;

  Future<String?> _readToken(String key) async {
    String? secured;
    try {
      secured = await _storage.read(key: key);
    } catch (_) {
      // Some test/desktop environments don't register the secure-storage plugin.
    }
    if (secured != null) return secured;
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(key);
    if (legacy != null) {
      try {
        await _storage.write(key: key, value: legacy);
        await prefs.remove(key);
      } catch (_) {
        // Keep the legacy value until secure storage is available.
      }
    }
    return legacy;
  }

  Future<String?> get accessToken => _readToken(_accessTokenKey);
  Future<String?> get refreshToken => _readToken(_refreshTokenKey);

  Future<void> setTokens({required String accessToken, required String refreshToken}) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
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

  Future<bool> _performRefresh() async {
    final refresh = await refreshToken;
    if (refresh == null) return false;
    final res = await http.post(
      Uri.parse('$kApiBaseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refresh}),
    ).timeout(_requestTimeout);
    if (res.statusCode != 200) {
      await clearTokens();
      return false;
    }
    final data = jsonDecode(res.body);
    await setTokens(accessToken: data['accessToken'], refreshToken: data['refreshToken']);
    return true;
  }

  Future<bool> _tryRefresh() {
    final running = _refreshInFlight;
    if (running != null) return running;
    final refresh = _performRefresh();
    _refreshInFlight = refresh;
    return refresh.whenComplete(() => _refreshInFlight = null);
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
        res = await http.get(uri, headers: headers).timeout(_requestTimeout);
        break;
      case 'POST':
        res = await http.post(uri, headers: headers, body: body != null ? jsonEncode(body) : null).timeout(_requestTimeout);
        break;
      case 'PATCH':
        res = await http.patch(uri, headers: headers, body: body != null ? jsonEncode(body) : null).timeout(_requestTimeout);
        break;
      case 'DELETE':
        res = await http.delete(uri, headers: headers).timeout(_requestTimeout);
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
