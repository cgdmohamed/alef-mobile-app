import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/misc.dart';
import '../../data/mock_data.dart';
import 'widgets/notification_bell.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  const AvatarPlaceholder(size: 42, color: AppColors.primaryLight),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('لمى عبدالله', style: tj(15, weight: FontWeight.w700, color: AppColors.textHeading)),
                        Text('الصف السادس ▾', style: tj(11, color: AppColors.textFaint)),
                      ],
                    ),
                  ),
                  const NotificationBell(),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      radius: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('الأداء العام', style: tj(11, color: AppColors.textFaint)),
                              Text('92%', style: tj(24, weight: FontWeight.w800, color: AppColors.textHeading)),
                            ],
                          ),
                          const StatusBadge(
                            label: 'ممتاز',
                            fg: AppColors.success,
                            bg: AppColors.successBg,
                            fontSize: 11,
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            radius: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: const [
                        Expanded(child: StatTile(value: '96%', label: 'الحضور', valueColor: AppColors.sky, valueSize: 15, labelSize: 9)),
                        SizedBox(width: 8),
                        Expanded(child: StatTile(value: '14', label: 'الواجبات', valueColor: AppColors.primary, valueSize: 15, labelSize: 9)),
                        SizedBox(width: 8),
                        Expanded(child: StatTile(value: '12', label: 'الإنجازات', valueColor: AppColors.warning, valueSize: 15, labelSize: 9)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AppCard(
                      radius: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('المهارات الرئيسية', style: tj(12, weight: FontWeight.w700, color: AppColors.textHeading)),
                          const SizedBox(height: 10),
                          Column(
                            children: [
                              for (final s in MockData.skillScores.take(3)) ...[
                                LabeledProgress(label: s.label, percent: s.percent, color: s.color),
                                if (s.label != MockData.skillScores[2].label) const SizedBox(height: 8),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppCard(
                      radius: 16,
                      child: Row(
                        children: [
                          const AvatarPlaceholder(size: 40, color: AppColors.inputFill),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('أ. منيرة السالم', style: tj(12, weight: FontWeight.w700, color: AppColors.textBody)),
                                Text('أخصائي الموهبة', style: tj(10, color: AppColors.textFaint)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/support'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(9)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const AppIcon(IconBodies.chat, size: 12, color: Colors.white, strokeWidth: 1.8),
                                  const SizedBox(width: 5),
                                  Text('دردشة', style: tj(10, weight: FontWeight.w600, color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
