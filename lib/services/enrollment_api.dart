import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

const _pendingCodeKey = 'alef_pending_enrollment_code';

/// Redeeming a join code requires an authenticated STUDENT (see the
/// backend's EnrollmentCodesController), but the code is entered before an
/// account exists (school-code screen, step 1 of signup). So the code is
/// stashed locally right after entry and redeemed automatically the first
/// time the new account logs in via OTP (see AppState.verifyOtp) — the app
/// may well be closed in between, since signup ends with "log in to
/// continue" rather than an active session.
class EnrollmentApi {
  EnrollmentApi._();
  static final EnrollmentApi instance = EnrollmentApi._();
  final _client = ApiClient.instance;

  Future<void> savePendingCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingCodeKey, code);
  }

  /// Returns the stashed code (if any) and clears it — a code is redeemed
  /// at most once, whether that attempt succeeds or fails.
  Future<String?> takePendingCode() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_pendingCodeKey);
    if (code != null) await prefs.remove(_pendingCodeKey);
    return code;
  }

  /// Reads the stashed code without clearing it — for display only (e.g.
  /// signup_screen showing what code will be redeemed after login).
  Future<String?> peekPendingCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pendingCodeKey);
  }

  Future<void> redeem(String code) async {
    await _client.post('/enrollment/redeem', {'code': code});
  }
}
