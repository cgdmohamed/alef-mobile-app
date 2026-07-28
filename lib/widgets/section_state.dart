import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';

/// Wraps the 5 screens the design gives explicit loading/empty/(error)
/// variants for (Home, Meetings, Assignments, Achievements, Notifications).
///
/// On first mount it shows [loading] for [initialDelay] to simulate a real
/// fetch, then falls through to [content] — unless [isEmpty] says the data
/// is organically empty (e.g. a search with no matches), or the Settings
/// screen's "معاينة الحالات" demo switch is forcing a particular state for
/// a walkthrough/QA look.
class SectionState extends StatefulWidget {
  final DemoSection section;
  final Duration initialDelay;
  final WidgetBuilder loading;
  final WidgetBuilder empty;
  final WidgetBuilder? error;
  final bool Function(BuildContext context)? isEmpty;
  final WidgetBuilder content;

  const SectionState({
    super.key,
    required this.section,
    required this.loading,
    required this.empty,
    this.error,
    this.isEmpty,
    required this.content,
    this.initialDelay = const Duration(milliseconds: 700),
  });

  @override
  State<SectionState> createState() => _SectionStateState();
}

class _SectionStateState extends State<SectionState> {
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.initialDelay, () {
      if (mounted) setState(() => _initialLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final demo = context.watch<AppState>().demoState[widget.section]!;

    if (_initialLoading || demo == ViewState.loading) {
      return widget.loading(context);
    }
    if (demo == ViewState.error && widget.error != null) {
      return widget.error!(context);
    }
    if (demo == ViewState.empty || (widget.isEmpty?.call(context) ?? false)) {
      return widget.empty(context);
    }
    return widget.content(context);
  }
}
