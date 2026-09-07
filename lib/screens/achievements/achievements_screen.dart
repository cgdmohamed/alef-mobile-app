import 'package:flutter/material.dart';
import '../../services/achievements_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/misc.dart';
import '../../widgets/section_state.dart';
import '../../state/app_state.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      appBar: AppBar(title: Text('الإنجازات', style: tj(20, weight: FontWeight.w800, color: AppColors.textHeading))),
      body: SafeArea(
        top: false,
        child: SectionState(
          section: DemoSection.achievements,
          loading: (context) => const _AchievementsLoading(),
          empty: (context) => const _AchievementsEmpty(),
          content: (context) => const _AchievementsContent(),
        ),
      ),
    );
  }
}

class _AchievementsContent extends StatefulWidget {
  const _AchievementsContent();

  @override
  State<_AchievementsContent> createState() => _AchievementsContentState();
}

class _AchievementsContentState extends State<_AchievementsContent> {
  bool _loading = true;
  String? _error;
  List<ApiBadge> _badges = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await AchievementsApi.instance.myAchievements();
      if (!mounted) return;
      setState(() {
        _badges = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'تعذر تحميل الإنجازات';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_error != null) {
      return StateMessage(
        icon: Text('!', style: tj(40, color: AppColors.coral)),
        iconBg: AppColors.dangerBg,
        title: 'تعذر تحميل الإنجازات',
        subtitle: 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى',
        actionLabel: 'إعادة المحاولة',
        onAction: _load,
      );
    }

    final unlocked = _badges.where((b) => !b.locked).length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$unlocked من ${_badges.length}', style: tj(12, weight: FontWeight.w600, color: AppColors.textFaint)),
          ],
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.95,
          children: [for (final b in _badges) _BadgeTile(badge: b)],
        ),
      ],
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final ApiBadge badge;
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
