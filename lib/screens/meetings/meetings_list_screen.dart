import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/buttons.dart';
import '../../widgets/misc.dart';
import '../../widgets/section_state.dart';

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

  List<Meeting> _filtered(List<Meeting> all) {
    return all.where((m) {
      final matchesSearch = _search.text.trim().isEmpty || m.title.contains(_search.text.trim());
      final matchesFilter = switch (_filter) {
        _MeetingFilter.all => true,
        _MeetingFilter.upcoming => m.status != MeetingStatus.ended,
        _MeetingFilter.ended => m.status == MeetingStatus.ended,
      };
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final all = context.watch<AppState>().meetings;
    final filtered = _filtered(all);

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
              child: SectionState(
                section: DemoSection.meetings,
                loading: (context) => const _MeetingsLoading(),
                empty: (context) => const _MeetingsEmpty(),
                isEmpty: (context) => filtered.isEmpty,
                content: (context) => _calendarView ? _CalendarView(meetings: all) : _MeetingsList(meetings: filtered),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeetingsList extends StatelessWidget {
  final List<Meeting> meetings;
  const _MeetingsList({required this.meetings});

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<Meeting>>{};
    for (final m in meetings) {
      groups.putIfAbsent(m.group, () => []).add(m);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      children: [
        for (final group in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 6, top: 4),
            child: Text(group.key, style: tj(12, weight: FontWeight.w700, color: AppColors.textFaint)),
          ),
          for (final m in group.value) ...[
            _MeetingCard(meeting: m),
            const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }
}

class _MeetingCard extends StatelessWidget {
  final Meeting meeting;
  const _MeetingCard({required this.meeting});

  @override
  Widget build(BuildContext context) {
    final ended = meeting.status == MeetingStatus.ended;
    return GestureDetector(
      onTap: () {
        if (meeting.status == MeetingStatus.liveNow) {
          context.push('/meeting/live/${meeting.id}');
        } else if (ended) {
          context.push('/meeting/recording/${meeting.id}');
        }
      },
      child: Opacity(
        opacity: ended ? 0.75 : 1,
        child: AppCard(
          border: meeting.status == MeetingStatus.liveNow
              ? const Border(right: BorderSide(color: AppColors.coral, width: 3))
              : null,
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
              Text('${meeting.timeLabel} • ${meeting.teacher}', style: tj(11, color: AppColors.textFaint)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(MeetingStatus status) {
    return switch (status) {
      MeetingStatus.liveNow => const StatusBadge(label: 'مباشر الآن', fg: AppColors.coral, bg: AppColors.dangerBg),
      MeetingStatus.upcoming => const StatusBadge(label: 'قادم', fg: AppColors.success, bg: AppColors.successBg),
      MeetingStatus.ended => Text('منتهٍ', style: tj(10, color: AppColors.textFaint)),
    };
  }
}

class _CalendarView extends StatefulWidget {
  final List<Meeting> meetings;
  const _CalendarView({required this.meetings});

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
                hasMeeting: d == now.day || d == now.day + 1,
                onTap: () => setState(() => _selected = DateTime(now.year, now.month, d)),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text('لقاءات اليوم المحدد', style: tj(12, weight: FontWeight.w700, color: AppColors.textHeading)),
        const SizedBox(height: 8),
        if (_selected.day == now.day)
          for (final m in widget.meetings.where((m) => m.group == 'اليوم')) ...[
            _MeetingCard(meeting: m),
            const SizedBox(height: 10),
          ]
        else if (_selected.day == now.day + 1)
          for (final m in widget.meetings.where((m) => m.group == 'غدًا')) ...[
            _MeetingCard(meeting: m),
            const SizedBox(height: 10),
          ]
        else
          Text('لا توجد لقاءات في هذا اليوم', style: tj(12, color: AppColors.textFaint)),
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
