import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/misc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          children: [
            Row(children: [
              const BackChevron(),
              const SizedBox(width: 8),
              Text('الإعدادات', style: tj(18, weight: FontWeight.w800, color: AppColors.textHeading)),
            ]),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الحساب', style: tj(12, weight: FontWeight.w700, color: AppColors.textHeading)),
                  const SizedBox(height: 6),
                  Text('تسجيل الدخول محمي برمز تحقق يُرسل إلى بريدك الإلكتروني، ولا يستخدم التطبيق كلمة مرور.', style: tj(11, color: AppColors.textMuted, height: 1.7)),
                ],
              ),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 20),
              Text('معاينة حالات الشاشات', style: tj(12, weight: FontWeight.w700, color: AppColors.textHeading)),
              const SizedBox(height: 10),
              const _DemoStatesPanel(),
            ],
          ],
        ),
      ),
    );
  }
}

class _DemoStatesPanel extends StatelessWidget {
  const _DemoStatesPanel();

  static const _sections = [
    (DemoSection.home, 'الرئيسية', true),
    (DemoSection.meetings, 'اللقاءات', false),
    (DemoSection.assignments, 'الواجبات', false),
    (DemoSection.achievements, 'الإنجازات', false),
    (DemoSection.notifications, 'الإشعارات', false),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          for (final section in _sections) ...[
            Align(alignment: Alignment.centerRight, child: Text(section.$2, style: tj(11, weight: FontWeight.w700, color: AppColors.textHeading))),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: [
                for (final option in [ViewState.normal, ViewState.loading, ViewState.empty, if (section.$3) ViewState.error])
                  ChoiceChip(
                    label: Text(_label(option), style: tj(10)),
                    selected: appState.demoState[section.$1] == option,
                    onSelected: (_) => appState.setDemoState(section.$1, option),
                  ),
              ],
            ),
            if (section != _sections.last) const Divider(color: AppColors.divider),
          ],
        ],
      ),
    );
  }

  String _label(ViewState state) => switch (state) {
    ViewState.normal => 'عادي',
    ViewState.loading => 'تحميل',
    ViewState.empty => 'فارغ',
    ViewState.error => 'خطأ',
  };
}
