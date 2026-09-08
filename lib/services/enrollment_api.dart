import 'package:shared_preferences/shared_preferences.dart';

const _pendingCodeKey = 'alef_pending_enrollment_code';

/// Keeps the school code between the two signup screens. The API validates
/// and consumes it atomically while creating the student account.
class EnrollmentApi {
  EnrollmentApi._();
  static final EnrollmentApi instance = EnrollmentApi._();
  final _client = ApiClient.instance;

  Future<void> savePendingCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingCodeKey, code);
  }

  Future<void> clearPendingCode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingCodeKey);
  }

  /// Reads the stashed code without clearing it for the details step.
  Future<String?> peekPendingCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pendingCodeKey);
  }
}
