import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/bottom_nav.dart';

/// Hosts the 5 bottom-tab branches (home/assignments/meetings/reports/
/// profile) behind the shared [AppBottomNav] — each tab owns its own
/// header/scaffolding internally, matching the design's per-screen layout.
class MainShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const MainShell({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: shell.currentIndex,
        isParent: context.watch<AppState>().role.name == 'parent',
        onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
      ),
    );
  }
}
