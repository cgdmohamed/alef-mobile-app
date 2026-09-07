import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/misc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _meetingNotifs = true;
  bool _assignmentNotifs = true;
  bool _messageNotifs = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          children: [
            Row(
              children: [
                const BackChevron(),
                const SizedBox(width: 8),
                Text('الإعدادات', style: tj(18, weight: FontWeight.w800, color: AppColors.textHeading)),
              ],
            ),
            const SizedBox(height: 14),
            _SettingsGroup(
              children: [
                _ToggleRow(label: 'إشعارات اللقاءات', value: _meetingNotifs, onChanged: (v) => setState(() => _meetingNotifs = v)),
                _ToggleRow(label: 'إشعارات الواجبات', value: _assignmentNotifs, onChanged: (v) => setState(() => _assignmentNotifs = v)),
                _ToggleRow(label: 'إشعارات الرسائل', value: _messageNotifs, onChanged: (v) => setState(() => _messageNotifs = v), last: true),
              ],
            ),
            const SizedBox(height: 12),
            _SettingsGroup(
              children: [
                _ValueRow(label: 'اللغة', value: 'العربية ▾'),
                _ValueRow(label: 'المظهر', value: 'فاتح ▾', last: true),
              ],
            ),
            const SizedBox(height: 12),
            _SettingsGroup(
              children: [
                _TapRow(
                  label: 'تغيير كلمة السر',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('إرسال رابط تغيير كلمة السر'))),
                ),
                _TapRow(
                  label: 'حذف الحساب',
                  color: AppColors.coral,
                  last: true,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى تأكيد حذف الحساب من بريدك الإلكتروني'))),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('معاينة الحالات (للعرض التجريبي)', style: tj(12, weight: FontWeight.w700, color: AppColors.textHeading)),
            const SizedBox(height: 4),
            Text('يتحكم في عرض حالات التحميل/الفارغة/الخطأ لكل شاشة', style: tj(10, color: AppColors.textFaint)),
            const SizedBox(height: 10),
            const _DemoStatesPanel(),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: children),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool last;
  const _ToggleRow({required this.label, required this.value, required this.onChanged, this.last = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: AppColors.inputFill))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: tj(12, color: AppColors.textBody)),
          AppSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  final String label;
  final String value;
  final bool last;
  const _ValueRow({required this.label, required this.value, this.last = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: AppColors.inputFill))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: tj(12, color: AppColors.textBody)),
          Text(value, style: tj(12, color: AppColors.textFaint)),
        ],
      ),
    );
  }
}

class _TapRow extends StatelessWidget {
  final String label;
  final Color color;
  final bool last;
  final VoidCallback onTap;
  const _TapRow({required this.label, this.color = AppColors.textBody, this.last = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: AppColors.inputFill))),
        child: Text(label, style: tj(12, color: color)),
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
          for (final s in _sections) ...[
            _DemoStateRow(
              label: s.$2,
              hasError: s.$3,
              value: appState.demoState[s.$1]!,
              onChanged: (v) => appState.setDemoState(s.$1, v),
            ),
            if (s != _sections.last) const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Divider(height: 1, color: AppColors.divider)),
          ],
        ],
      ),
    );
  }
}

class _DemoStateRow extends StatelessWidget {
  final String label;
  final bool hasError;
  final ViewState value;
  final ValueChanged<ViewState> onChanged;
  const _DemoStateRow({required this.label, required this.hasError, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = [
      (ViewState.normal, 'عادي'),
      (ViewState.loading, 'تحميل'),
      (ViewState.empty, 'فارغة'),
      if (hasError) (ViewState.error, 'خطأ'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: tj(11, weight: FontWeight.w700, color: AppColors.textHeading)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final o in options)
              GestureDetector(
                onTap: () => onChanged(o.$1),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: value == o.$1 ? AppColors.primary : AppColors.inputFill,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(o.$2, style: tj(10, weight: FontWeight.w600, color: value == o.$1 ? Colors.white : AppColors.textMuted)),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
