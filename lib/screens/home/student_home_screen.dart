import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/misc.dart';
import '../../widgets/section_state.dart';
import 'widgets/notification_bell.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        bottom: false,
        child: SectionState(
          section: DemoSection.home,
          loading: (context) => const _HomeLoading(),
          empty: (context) => const _HomeEmpty(),
          error: (context) => const _HomeError(),
          content: (context) => const _HomeContent(),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final assignments = context.watch<AppState>().assignments;
    final upcoming = assignments.where((a) => a.status == AssignmentStatus.inProgress).take(3).toList();

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('صباح الخير', style: tj(13, color: AppColors.textFaint)),
                    Text('لمى عبدالله', style: tj(19, weight: FontWeight.w800, color: AppColors.textHeading)),
                  ],
                ),
              ),
              Row(
                children: [
                  const NotificationBell(),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => context.go('/profile'),
                    child: const AvatarPlaceholder(size: 38, color: AppColors.primaryLight),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _LiveMeetingHero(),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.7,
                  children: const [
                    StatTile(value: '3', label: 'واجبات معلقة', valueColor: AppColors.coral),
                    StatTile(value: '96%', label: 'نسبة الحضور', valueColor: AppColors.sky),
                    StatTile(value: '12', label: 'الإنجازات', valueColor: AppColors.primary),
                    StatTile(value: '4.8', label: 'التقييم العام', valueColor: AppColors.warning),
                  ],
                ),
                const SizedBox(height: 16),
                Text('الواجبات القادمة', style: tj(13, weight: FontWeight.w700, color: AppColors.textHeading)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 96,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: upcoming.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final a = upcoming[i];
                      return SizedBox(
                        width: 130,
                        child: GestureDetector(
                          onTap: () => context.push('/assignment/${a.id}'),
                          child: AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: tj(12, weight: FontWeight.w700, color: AppColors.textBody),
                                ),
                                const SizedBox(height: 4),
                                Text(_dueLabel(a), style: tj(10, color: AppColors.textFaint)),
                                const SizedBox(height: 8),
                                ProgressTrack(value: a.progress == 0 ? 0.2 : a.progress),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text('التسجيلات السابقة', style: tj(13, weight: FontWeight.w700, color: AppColors.textHeading)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _RecordingTile(id: 'm4', title: 'أساسيات الهندسة', length: '42:10')),
                    const SizedBox(width: 10),
                    Expanded(child: _RecordingTile(id: 'm4', title: 'القراءة النقدية', length: '38:05')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _dueLabel(Assignment a) {
    switch (a.id) {
      case 'a1':
        return 'يسلّم غدًا';
      case 'a2':
        return '3 أيام متبقية';
      default:
        return 'يسلّم بعد أسبوع';
    }
  }
}

class _LiveMeetingHero extends StatelessWidget {
  const _LiveMeetingHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('لقاء اليوم', style: tj(11, weight: FontWeight.w500, color: const Color(0xFFC7C4EF))),
          const SizedBox(height: 6),
          Text('أساسيات الهندسة الإبداعية', style: tj(16, weight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 8),
          Row(
            children: [
              const AppIcon(IconBodies.clock, size: 12, color: Color(0xFFDEDCF9), strokeWidth: 1.8),
              const SizedBox(width: 4),
              Text('5:00 م', style: tj(12, color: const Color(0xFFDEDCF9))),
              const SizedBox(width: 8),
              Text('•', style: tj(12, color: const Color(0xFFDEDCF9))),
              const SizedBox(width: 8),
              Text('أ. سلطان العتيبي', style: tj(12, color: const Color(0xFFDEDCF9))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('بعد ساعة و20 دقيقة', style: tj(11, weight: FontWeight.w600, color: AppColors.gold)),
              GestureDetector(
                onTap: () => context.push('/meeting/live/m1'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: Text('انضم للقاء', style: tj(12, weight: FontWeight.w700, color: AppColors.primary)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecordingTile extends StatelessWidget {
  final String id;
  final String title;
  final String length;
  const _RecordingTile({required this.id, required this.title, required this.length});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/meeting/recording/$id'),
      child: Container(
        height: 70,
        padding: const EdgeInsets.all(8),
        alignment: Alignment.bottomRight,
        decoration: BoxDecoration(color: AppColors.liveSurface, borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            const Positioned(
              top: 0,
              left: 0,
              child: AppIcon(IconBodies.lock, size: 13, color: Colors.white, strokeWidth: 1.8),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Text('$title • $length', style: tj(9, weight: FontWeight.w600, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Skeleton(height: 130, radius: 18),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.9,
            children: const [
              Skeleton(height: 60),
              Skeleton(height: 60),
              Skeleton(height: 60),
              Skeleton(height: 60),
            ],
          ),
          const SizedBox(height: 16),
          const Skeleton(height: 90),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text('جارِ التحميل...', style: tj(12, weight: FontWeight.w500, color: AppColors.textDisabled)),
          ),
        ],
      ),
    );
  }
}

class _HomeEmpty extends StatelessWidget {
  const _HomeEmpty();

  @override
  Widget build(BuildContext context) {
    return StateMessage(
      icon: const AppIcon(IconBodies.calendar, size: 34, color: AppColors.primary, strokeWidth: 1.6),
      iconBg: AppColors.inputFill,
      title: 'لا توجد لقاءات اليوم',
      subtitle: 'استمتع بيومك! ستظهر لقاءاتك القادمة هنا فور جدولتها',
      actionLabel: 'عرض كل اللقاءات',
      onAction: () => context.go('/meetings'),
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError();

  @override
  Widget build(BuildContext context) {
    return StateMessage(
      icon: Text('!', style: tj(40, color: AppColors.coral)),
      iconBg: AppColors.dangerBg,
      title: 'تعذر تحميل البيانات',
      subtitle: 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى',
      actionLabel: 'إعادة المحاولة',
      onAction: () => context.read<AppState>().setDemoState(DemoSection.home, ViewState.normal),
    );
  }
}
