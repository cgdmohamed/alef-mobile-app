import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/misc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
              decoration: const BoxDecoration(gradient: AppColors.profileHeaderGradient),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: GestureDetector(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعديل الملف الشخصي'))),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(9)),
                        alignment: Alignment.center,
                        child: const AppIcon(IconBodies.pencil, size: 14, color: Colors.white, strokeWidth: 1.8),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      const AvatarPlaceholder(size: 84, color: AppColors.primaryLight),
                      const SizedBox(height: 10),
                      Text('لمى عبدالله الحربي', style: tj(17, weight: FontWeight.w800, color: Colors.white)),
                      Text('طالبة — الصف السادس ابتدائي', style: tj(12, color: const Color(0xFFDEDCF9))),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: StatTile(value: '5', label: 'المستوى', valueColor: AppColors.primary, valueSize: 15, labelSize: 9)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.push('/achievements'),
                          child: StatTile(value: '12', label: 'شارة', valueColor: AppColors.warning, valueSize: 15, labelSize: 9),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: StatTile(value: '96%', label: 'الحضور', valueColor: AppColors.sky, valueSize: 15, labelSize: 9)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      children: [
                        _InfoRow(label: 'البريد الإلكتروني', value: 'lama.h@email.com'),
                        const SizedBox(height: 10),
                        _InfoRow(label: 'المدرسة', value: 'مدارس الرؤية الأهلية'),
                        const SizedBox(height: 10),
                        _InfoRow(label: 'ولي الأمر', value: 'عبدالله الحربي'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _MenuRow(icon: IconBodies.gear, label: 'الإعدادات', onTap: () => context.push('/settings')),
                        _MenuRow(icon: IconBodies.docLines, label: 'التقارير', onTap: () => context.go('/reports')),
                        _MenuRow(icon: IconBodies.medal, label: 'الإنجازات', strokeWidth: 1.6, onTap: () => context.push('/achievements')),
                        _MenuRow(icon: IconBodies.chat, label: 'خدمة العملاء', onTap: () => context.push('/support')),
                        _MenuRow(
                          icon: IconBodies.logout,
                          label: 'تسجيل خروج',
                          color: AppColors.coral,
                          last: true,
                          onTap: () => context.go('/login'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: tj(11, color: AppColors.textMuted)),
        Text(value, style: tj(11, color: AppColors.textBody)),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final double strokeWidth;
  final bool last;
  final VoidCallback onTap;
  const _MenuRow({
    required this.icon,
    required this.label,
    this.color = AppColors.textBody,
    this.strokeWidth = 1.8,
    this.last = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          border: last ? null : const Border(bottom: BorderSide(color: AppColors.inputFill)),
        ),
        child: Row(
          children: [
            AppIcon(icon, size: 15, color: color == AppColors.textBody ? AppColors.textMuted : color, strokeWidth: strokeWidth),
            const SizedBox(width: 10),
            Text(label, style: tj(12, weight: FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }
}
