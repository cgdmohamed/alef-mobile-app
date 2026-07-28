import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/models.dart';

/// The 5 screens the design gives explicit loading/empty/(error) variants
/// for — surfaced here so Settings can flip each one for a demo/QA look
/// without needing a real failing backend.
enum DemoSection { home, meetings, assignments, achievements, notifications }

/// Single source of truth for the whole running app: role switch, the
/// mutable mock collections (so completing an assignment or reading a
/// notification is reflected everywhere), and the demo view-state per
/// section used to preview the design's loading/empty/error screens.
class AppState extends ChangeNotifier {
  UserRole role = UserRole.student;

  final List<Assignment> assignments = MockData.assignments();
  final List<AppNotification> notifications = MockData.notifications();
  final List<Meeting> meetings = MockData.meetings();

  final Map<DemoSection, ViewState> demoState = {
    for (final s in DemoSection.values) s: ViewState.normal,
  };

  int get unreadNotifications => notifications.where((n) => !n.read).length;

  void setRole(UserRole r) {
    role = r;
    notifyListeners();
  }

  void setDemoState(DemoSection section, ViewState state) {
    demoState[section] = state;
    notifyListeners();
  }

  void completeAssignment(String id) {
    final a = assignments.firstWhere((a) => a.id == id);
    a.status = AssignmentStatus.submitted;
    notifyListeners();
  }

  void markAllNotificationsRead() {
    for (final n in notifications) {
      n.read = true;
    }
    notifyListeners();
  }

  void markNotificationRead(String id) {
    notifications.firstWhere((n) => n.id == id).read = true;
    notifyListeners();
  }
}
