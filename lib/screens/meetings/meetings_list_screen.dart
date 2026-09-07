import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/meetings_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/buttons.dart';
import '../../widgets/misc.dart';

enum _MeetingFilter { all, upcoming, ended }

class MeetingsListScreen extends StatefulWidget {
  const MeetingsListScreen({super.key});

  @override
  State<MeetingsListScreen> createState() => _MeetingsListScreenState();
}

class _MeetingsListScreenState extends State<MeetingsListScreen> {
  final _search = TextEditingController();
  _MeetingFilter _filter = _MeetingFilter.all;
  bool _calendarView = false;
  bool _loading = true;
  String? _error;
  List<ApiMeeting> _all = [];

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
      final data = await MeetingsApi.instance.list();
      if (!mounted) return;
      setState(() {
        _all = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'تعذر تحميل اللقاءات';
        _loading = false;
      });
    }
  }

  String _group(ApiMeeting m) {
    if (m.status == 'ended') return 'منتهية';
    final now = DateTime.now();
    final diff = m.scheduledAt.difference(DateTime(now.year, now.month, now.day)).inDays;
    if (diff <= 0) return 'اليوم';
    if (diff == 1) return 'غدًا';
    return 'هذا الأسبوع';
  }

  List<ApiMeeting> _filtered(List<ApiMeeting> all) {
    return all.where((m) {
      final matchesSearch = _search.text.trim().isEmpty || m.title.contains(_search.text.trim());
      final matchesFilter = switch (_filter) {
        _MeetingFilter.all => true,
        _MeetingFilter.upcoming => m.status != 'ended',
        _MeetingFilter.ended => m.status == 'ended',
      };
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered(_all);

    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('اللقاءات', style: tj(20, weight: FontWeight.w800, color: AppColors.textHeading)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(11)),
                    child: Row(
                      children: [
                        const AppIcon(IconBodies.search, size: 14, color: AppColors.textFaint, strokeWidth: 2),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _search,
                            textAlign: TextAlign.right,
                            onChanged: (_) => setState(() {}),
                            style: tj(12, color: AppColors.textBody),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              hintText: 'بحث عن لقاء',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      PillChip(label: 'الكل', active: _filter == _MeetingFilter.all, onTap: () => setState(() => _filter = _MeetingFilter.all)),
                      const SizedBox(width: 8),
                      PillChip(label: 'قادم', active: _filter == _MeetingFilter.upcoming, onTap: () => setState(() => _filter = _MeetingFilter.upcoming)),
                      const SizedBox(width: 8),
                      PillChip(label: 'منتهٍ', active: _filter == _MeetingFilter.ended, onTap: () => setState(() => _filter = _MeetingFilter.ended)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _calendarView = false),
                        child: PillChip(
                          label: 'قائمة',
                          active: !_calendarView,
                          fontSize: 10,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          icon: AppIcon(IconBodies.list, size: 12, color: !_calendarView ? Colors.white : AppColors.primary, strokeWidth: 1.8),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => setState(() => _calendarView = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: _calendarView ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppIcon(IconBodies.calendar, size: 12, color: _calendarView ? Colors.white : AppColors.textFaint, strokeWidth: 1.8),
                              const SizedBox(width: 4),
                              Text('تقويم', style: tj(10, weight: FontWeight.w600, color: _calendarView ? Colors.white : AppColors.textFaint)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const _MeetingsLoading()
                  : _error != null
                      ? StateMessage(
                          icon: Text('!', style: tj(40, color: AppColors.coral)),
                          iconBg: AppColors.dangerBg,
                          title: 'تعذر تحميل اللقاءات',
                          subtitle: 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى',
                          actionLabel: 'إعادة المحاولة',
                          onAction: _load,
                        )
                      : filtered.isEmpty
                          ? const _MeetingsEmpty()
                          : (_calendarView ? _CalendarView(meetings: _all, group: _group) : _MeetingsList(meetings: filtered, group: _group)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeetingsList extends StatelessWidget {
  final List<ApiMeeting> meetings;
  final String Function(ApiMeeting) group;
  const _MeetingsList({required this.meetings, required this.group});

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<ApiMeeting>>{};
    for (final m in meetings) {
      groups.putIfAbsent(group(m), () => []).add(m);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      children: [
        for (final g in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 6, top: 4),
            child: Text(g.key, style: tj(12, weight: FontWeight.w700, color: AppColors.textFaint)),
          ),
          for (final m in g.value) ...[
            _MeetingCard(meeting: m),
            const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }
}

class _MeetingCard extends StatelessWidget {
  final ApiMeeting meeting;
  const _MeetingCard({required this.meeting});

  @override
  Widget build(BuildContext context) {
    final ended = meeting.status == 'ended';
    final live = meeting.status == 'live';
    return GestureDetector(
      onTap: () {
        if (live) {
          context.push('/meeting/live/${meeting.id}');
        } else if (ended) {
          context.push('/meeting/recording/${meeting.id}');
        }
      },
      child: Opacity(
        opacity: ended ? 0.75 : 1,
        child: AppCard(
          border: live ? const Border(right: BorderSide(color: AppColors.coral, width: 3)) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (ended) ...[
                          const AppIcon(IconBodies.mic, size: 13, color: AppColors.textFaint, strokeWidth: 1.8),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            meeting.title,
                            style: tj(13, weight: FontWeight.w700, color: AppColors.textBody),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusBadge(meeting.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${meeting.scheduledAt.hour.toString().padLeft(2, '0')}:${meeting.scheduledAt.minute.toString().padLeft(2, '0')} • ${meeting.teacherName ?? ''}',
                style: tj(11, color: AppColors.textFaint),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    return switch (status) {
      'live' => const StatusBadge(label: 'مباشر الآن', fg: AppColors.coral, bg: AppColors.dangerBg),
      'ended' => Text('منتهٍ', style: tj(10, color: AppColors.textFaint)),
      _ => const StatusBadge(label: 'قادم', fg: AppColors.success, bg: AppColors.successBg),
    };
  }
}

class _CalendarView extends StatefulWidget {
  final List<ApiMeeting> meetings;
  final String Function(ApiMeeting) group;
  const _CalendarView({required this.meetings, required this.group});

  @override
  State<_CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<_CalendarView> {
  late DateTime _selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final leading = firstOfMonth.weekday % 7;
    final selectedMeetings = widget.meetings
        .where((m) => m.scheduledAt.year == _selected.year && m.scheduledAt.month == _selected.month && m.scheduledAt.day == _selected.day)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      children: [
        Text('${now.year} / ${now.month}', style: tj(13, weight: FontWeight.w700, color: AppColors.textHeading)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (var i = 0; i < leading; i++) const SizedBox.shrink(),
            for (var d = 1; d <= daysInMonth; d++)
              _CalendarDay(
                day: d,
                isToday: d == now.day,
                isSelected: d == _selected.day,
                hasMeeting: widget.meetings.any((m) => m.scheduledAt.year == now.year && m.scheduledAt.month == now.month && m.scheduledAt.day == d),
                onTap: () => setState(() => _selected = DateTime(now.year, now.month, d)),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text('لقاءات اليوم المحدد', style: tj(12, weight: FontWeight.w700, color: AppColors.textHeading)),
        const SizedBox(height: 8),
        if (selectedMeetings.isEmpty)
          Text('لا توجد لقاءات في هذا اليوم', style: tj(12, color: AppColors.textFaint))
        else
          for (final m in selectedMeetings) ...[
            _MeetingCard(meeting: m),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _CalendarDay extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isSelected;
  final bool hasMeeting;
  final VoidCallback onTap;
  const _CalendarDay({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.hasMeeting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$day',
              style: tj(11, weight: isToday ? FontWeight.w700 : FontWeight.w400, color: isSelected ? Colors.white : AppColors.textBody),
            ),
            if (hasMeeting)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 4,
                height: 4,
                decoration: BoxDecoration(color: isSelected ? Colors.white : AppColors.coral, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}

class _MeetingsLoading extends StatelessWidget {
  const _MeetingsLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      children: const [
        Skeleton(height: 70, radius: 14),
        SizedBox(height: 12),
        Skeleton(height: 70, radius: 14),
        SizedBox(height: 12),
        Skeleton(height: 70, radius: 14),
      ],
    );
  }
}

class _MeetingsEmpty extends StatelessWidget {
  const _MeetingsEmpty();

  @override
  Widget build(BuildContext context) {
    return const StateMessage(
      icon: AppIcon(IconBodies.search, size: 32, color: AppColors.primary, strokeWidth: 1.6),
      iconBg: AppColors.inputFill,
      title: 'لا نتائج مطابقة',
      subtitle: 'جرّب كلمة بحث أخرى أو غيّر الفلتر',
    );
  }
}
