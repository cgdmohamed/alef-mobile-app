// ignore_for_file: use_null_aware_elements

import 'api_client.dart';

class AuthUser {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String role;
  final String? schoolId;
  final String status;

  AuthUser({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.role,
    this.schoolId,
    required this.status,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        phone: json['phone'],
        role: json['role'],
        schoolId: json['schoolId'],
        status: json['status'],
      );
}

class AuthResult {
  final AuthUser user;
  AuthResult(this.user);
}

class AuthApi {
  AuthApi._();
  static final AuthApi instance = AuthApi._();
  final _client = ApiClient.instance;

  Future<void> requestOtp(String email) async {
    await _client.post('/auth/otp/request', {'email': email});
  }

  Future<AuthResult> verifyOtp(String email, String code) async {
    final data = await _client.post('/auth/otp/verify', {'email': email, 'code': code});
    await _client.setTokens(accessToken: data['accessToken'], refreshToken: data['refreshToken']);
    return AuthResult(AuthUser.fromJson(data['user']));
  }

  Future<AuthUser> signup({
    required String name,
    required String email,
    String? phone,
    required String role,
    String? enrollmentCode,
    String? stage,
    String? parentName,
    String? parentEmail,
    String? parentPhone,
  }) async {
    final data = await _client.post('/auth/signup', {
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      'role': role,
      if (enrollmentCode != null) 'enrollmentCode': enrollmentCode,
      if (stage != null) 'stage': stage,
      if (parentName != null) 'parentName': parentName,
      if (parentEmail != null) 'parentEmail': parentEmail,
      if (parentPhone != null) 'parentPhone': parentPhone,
    });
    return AuthUser.fromJson(data);
  }

  Future<AuthUser> parentConsent(String studentId) async {
    final data = await _client.post('/auth/parent-consent', {'studentId': studentId});
    return AuthUser.fromJson(data);
  }

  Future<AuthUser?> me() async {
    try {
      final data = await _client.get('/auth/me');
      return AuthUser.fromJson(data);
    } on ApiException catch (e) {
      if (e.status == 401) return null;
      rethrow;
    }
  }

  Future<void> logout() async {
    final refresh = await _client.refreshToken;
    if (refresh != null) {
      try {
        await _client.post('/auth/logout', {'refreshToken': refresh});
      } catch (_) {
        // best-effort — clear local tokens regardless
      }
    }
    await _client.clearTokens();
  }
}
