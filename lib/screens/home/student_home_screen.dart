import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/assignments_api.dart';
import '../../services/home_api.dart';
import '../../services/meetings_api.dart';
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

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  StudentHomeData? _home;
  List<ApiAssignment> _assignments = [];
  List<ApiMeeting> _recordings = [];
  bool _loading = true;
  String? _error;

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
      final results = await Future.wait([
        HomeApi.instance.studentHome(),
        AssignmentsApi.instance.myAssignments(),
        MeetingsApi.instance.list(),
      ]);
      if (!mounted) return;
      setState(() {
        _home = results[0] as StudentHomeData?;
        _assignments = results[1] as List<ApiAssignment>;
        _recordings = (results[2] as List<ApiMeeting>).where((m) => m.status == 'ended').take(3).toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'تعذر تحميل البيانات';
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
        title: 'تعذر تحميل البيانات',
        subtitle: 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى',
        actionLabel: 'إعادة المحاولة',
        onAction: _load,
      );
    }

    final upcoming = _assignments.where((a) => a.submissionStatus == null || a.submissionStatus == 'in_progress').take(3).toList();
    final nextMeeting = _home?.nextMeeting;

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
                    Text(_home?.studentName ?? '', style: tj(19, weight: FontWeight.w800, color: AppColors.textHeading)),
                  ],
                ),
              ),
              Row(
                children: [
                  const NotificationBell(),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => context.go('/profile'),
                    child: const AvatarPlaceholder(size: 38),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _LiveActivityBanner(),
                  const SizedBox(height: 12),
                  if (nextMeeting != null) _LiveMeetingHero(meeting: nextMeeting),
                  if (nextMeeting != null) const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.7,
                    children: [
                      StatTile(value: '${_home?.pendingAssignments.length ?? 0}', label: 'واجبات معلقة', valueColor: AppColors.coral),
                      StatTile(value: '${_home?.unreadNotifications ?? 0}', label: 'إشعارات جديدة', valueColor: AppColors.sky),
                      StatTile(value: '${_home?.points ?? 0}', label: 'النقاط', valueColor: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('الواجبات القادمة', style: tj(13, weight: FontWeight.w700, color: AppColors.textHeading)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 96,
                    child: upcoming.isEmpty
                        ? Center(child: Text('لا توجد واجبات حالية', style: tj(12, color: AppColors.textFaint)))
                        : ListView.separated(
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
                                        Text(
                                          '${a.dueAt.day}/${a.dueAt.month}',
                                          style: tj(10, color: AppColors.textFaint),
                                        ),
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
                  if (_recordings.isEmpty)
                    Text('لا توجد تسجيلات بعد', style: tj(12, color: AppColors.textFaint))
                  else
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.4,
                      children: [
                        for (final m in _recordings) _RecordingTile(id: m.id, title: m.title),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Trainer-pushed timed activity banner — always shown above the meeting
/// hero, matching the app's populated-demo-data philosophy. The countdown
/// is cosmetic (no real deadline behind it, same as the meeting hero's
/// static "بعد ساعة و20 دقيقة" label) — it just ticks down for realism.
class _LiveActivityBanner extends StatefulWidget {
  const _LiveActivityBanner();

  @override
  State<_LiveActivityBanner> createState() => _LiveActivityBannerState();
}

class _LiveActivityBannerState extends State<_LiveActivityBanner> {
  Timer? _timer;
  int _seconds = 4 * 60 + 32;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds == 0) {
        t.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mm = (_seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (_seconds % 60).toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.mint, AppColors.mintDark],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: AppColors.mint.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(
                child: Text('نشاط مباشر الآن — أرسله مدربك', style: tj(11, weight: FontWeight.w700, color: Colors.white)),
              ),
              Text('$mm:$ss', style: tj(11, weight: FontWeight.w700, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          Text('بحث عن الكلمات: مفاتيح التفكير', style: tj(16, weight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('يُغلق تلقائيًا بانتهاء الوقت', style: tj(11, color: const Color(0xFFDFF6EC))),
              ),
              GestureDetector(
                onTap: () => context.push('/live-activity'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: Text('ابدأ الآن', style: tj(12, weight: FontWeight.w800, color: AppColors.mintDark)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LiveMeetingHero extends StatelessWidget {
  final Map<String, dynamic> meeting;
  const _LiveMeetingHero({required this.meeting});

  @override
  Widget build(BuildContext context) {
    final title = meeting['title'] as String? ?? '';
    final id = meeting['id'] as String? ?? '';
    final teacherName = (meeting['classEntity'] as Map<String, dynamic>?)?['teacher']?['name'] as String?;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('لقاء اليوم', style: tj(11, weight: FontWeight.w500, color: const Color(0xFFC7C4EF))),
          const SizedBox(height: 6),
          Text(title, style: tj(16, weight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 8),
          if (teacherName != null)
            Row(
              children: [
                const AppIcon(IconBodies.clock, size: 12, color: Color(0xFFDEDCF9), strokeWidth: 1.8),
                const SizedBox(width: 4),
                Text(teacherName, style: tj(12, color: const Color(0xFFDEDCF9))),
              ],
            ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => context.push('/meeting/live/$id'),
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
  const _RecordingTile({required this.id, required this.title});

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
            Positioned(
              right: 0,
              left: 0,
              bottom: 0,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: tj(9, weight: FontWeight.w600, color: Colors.white),
              ),
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
    return SingleChildScrollView(
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
          const SizedBox(height: 24),
          Text('جارِ التحميل...', style: tj(12, weight: FontWeight.w500, color: AppColors.textDisabled)),
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
