import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/auth_api.dart';

/// Shared by every "*-loading/-empty/-error" screen variant in the design.
/// [error] is only meaningful on Home — it's the only screen the design
/// actually specifies an error state for (07d).
enum ViewState { normal, loading, empty, error }

/// Single source of truth for the whole running app: auth session and the
/// demo view-state per section used to preview the design's
/// loading/empty/error screens. Domain data (assignments, meetings,
/// notifications, ...) is fetched per-screen from the real API instead of
/// being held here, since it's no longer static mock data.
class AppState extends ChangeNotifier {
  AuthUser? currentUser;
  bool authLoading = true;

  final Map<DemoSection, ViewState> demoState = {
    for (final s in DemoSection.values) s: ViewState.normal,
  };

  UserRole get role => currentUser?.role == 'parent' ? UserRole.parent : UserRole.student;
  bool get isAuthenticated => currentUser != null;

  /// Called once at startup to restore a session from a stored token, if any.
  Future<void> bootstrap() async {
    authLoading = true;
    notifyListeners();
    currentUser = await AuthApi.instance.me();
    authLoading = false;
    notifyListeners();
  }

  Future<AuthUser> verifyOtp(String phone, String code) async {
    final result = await AuthApi.instance.verifyOtp(phone, code);
    currentUser = result.user;
    notifyListeners();
    return result.user;
  }

  Future<void> logout() async {
    await AuthApi.instance.logout();
    currentUser = null;
    notifyListeners();
  }

  void setDemoState(DemoSection section, ViewState state) {
    demoState[section] = state;
    notifyListeners();
  }
}

/// The 5 screens the design gives explicit loading/empty/(error) variants
/// for — surfaced here so Settings can flip each one for a demo/QA look
/// without needing a real failing backend.
enum DemoSection { home, meetings, assignments, achievements, notifications }
