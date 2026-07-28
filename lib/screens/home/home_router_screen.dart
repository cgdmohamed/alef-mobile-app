import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import 'student_home_screen.dart';
import 'parent_home_screen.dart';

/// The design gives Home two entirely different bodies depending on who's
/// signed in (student dashboard #07 vs. parent child-tracking #08) — this
/// just picks the right one off [AppState.role].
class HomeRouterScreen extends StatelessWidget {
  const HomeRouterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AppState>().role;
    return role == UserRole.student ? const StudentHomeScreen() : const ParentHomeScreen();
  }
}
