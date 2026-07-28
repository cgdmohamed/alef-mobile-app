import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'app_icon.dart';

class _NavItem {
  final String body;
  final String label;
  const _NavItem(this.body, this.label);
}

const _navItems = [
  _NavItem(IconBodies.home, 'الرئيسية'),
  _NavItem(IconBodies.docFold, 'الواجبات'),
  _NavItem(IconBodies.calendar, 'اللقاءات'),
  _NavItem(IconBodies.bars, 'التقارير'),
  _NavItem(IconBodies.person, 'حسابي'),
];

/// The 5-tab bottom bar reused verbatim across every shell screen in the
/// design (home / assignments / meetings / reports / profile).
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 14),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (i) {
            final item = _navItems[i];
            final active = i == currentIndex;
            final color = active ? AppColors.primary : AppColors.textDisabled;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIcon(item.body, size: 20, color: color, strokeWidth: 1.8),
                  const SizedBox(height: 3),
                  Text(
                    item.label,
                    style: tj(9, weight: active ? FontWeight.w600 : FontWeight.w400, color: color),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
