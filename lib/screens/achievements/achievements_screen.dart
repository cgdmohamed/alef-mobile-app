import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/misc.dart';
import '../../widgets/section_state.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      appBar: AppBar(title: Text('الإنجازات', style: tj(20, weight: FontWeight.w800, color: AppColors.textHeading))),
      body: SectionState(
        section: DemoSection.achievements,
        loading: (context) => const _AchievementsLoading(),
        empty: (context) => const _AchievementsEmpty(),
        content: (context) => const _AchievementsContent(),
      ),
    );
  }
}

class _AchievementsContent extends StatelessWidget {
  const _AchievementsContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('12 من 30', style: tj(12, weight: FontWeight.w600, color: AppColors.textFaint)),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(gradient: AppColors.leaderboardGradient, borderRadius: BorderRadius.circular(14)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('المستوى الحالي', style: tj(10, color: const Color(0xFFDEDCF9))),
                  Text('مستوى 5 — نجم صاعد', style: tj(16, weight: FontWeight.w800, color: Colors.white)),
                ],
              ),
              Text('2,340', style: tj(20, weight: FontWeight.w800, color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.95,
          children: [for (final b in MockData.badges) _BadgeTile(badge: b)],
        ),
        const SizedBox(height: 16),
        Text('شارات قريبة', style: tj(12, weight: FontWeight.w700, color: AppColors.textHeading)),
        const SizedBox(height: 8),
        AppCard(
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: const Text('⭐', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('بطل الحضور', style: tj(11, weight: FontWeight.w700, color: AppColors.textBody)),
                    Text('احضر لقاءين إضافيين لفتحها', style: tj(9, color: AppColors.textFaint)),
                    const SizedBox(height: 5),
                    const ProgressTrack(value: 0.7, color: AppColors.warning, height: 5),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('قائمة المتفوقين — الفصل', style: tj(12, weight: FontWeight.w700, color: AppColors.textHeading)),
            Text('الأسبوعي', style: tj(9, weight: FontWeight.w500, color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            children: [
              for (final e in MockData.leaderboard) ...[
                _LeaderRow(entry: e),
                if (e != MockData.leaderboard.last) const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final AchievementBadge badge;
  const _BadgeTile({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: badge.locked ? 0.4 : 1,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            badge.locked
                ? const AppIcon(IconBodies.lock, size: 24, color: AppColors.textDisabled, strokeWidth: 1.8)
                : Text(badge.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 4),
            Text(badge.label, textAlign: TextAlign.center, style: tj(9, weight: FontWeight.w500, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _LeaderRow extends StatelessWidget {
  final LeaderboardEntry entry;
  const _LeaderRow({required this.entry});

  static const _rankColors = {1: AppColors.warning, 2: AppColors.textDisabled, 3: AppColors.orangeAccent};

  @override
  Widget build(BuildContext context) {
    final isTop = entry.rank == 1;
    return Row(
      children: [
        SizedBox(
          width: 14,
          child: Text('${entry.rank}', style: tj(11, weight: FontWeight.w800, color: _rankColors[entry.rank])),
        ),
        const SizedBox(width: 8),
        Container(width: 26, height: 26, decoration: BoxDecoration(color: entry.color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(entry.name, style: tj(11, weight: isTop ? FontWeight.w700 : FontWeight.w400, color: AppColors.textBody)),
        ),
        Text('${entry.points}', style: tj(10, weight: FontWeight.w700, color: isTop ? AppColors.primary : AppColors.textFaint)),
      ],
    );
  }
}

class _AchievementsLoading extends StatelessWidget {
  const _AchievementsLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Skeleton(height: 70),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1,
            children: const [Skeleton(height: 80), Skeleton(height: 80), Skeleton(height: 80)],
          ),
        ],
      ),
    );
  }
}

class _AchievementsEmpty extends StatelessWidget {
  const _AchievementsEmpty();

  @override
  Widget build(BuildContext context) {
    return const StateMessage(
      icon: AppIcon(IconBodies.medal, size: 34, color: AppColors.primary, strokeWidth: 1.6),
      iconBg: AppColors.inputFill,
      title: 'ابدأ رحلتك!',
      subtitle: 'أكمل واجباتك ولقاءاتك لتحصل على أول شارة',
    );
  }
}
