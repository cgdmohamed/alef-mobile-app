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

enum _Tab { inProgress, submitted, late }

class AssignmentsListScreen extends StatefulWidget {
  const AssignmentsListScreen({super.key});

  @override
  State<AssignmentsListScreen> createState() => _AssignmentsListScreenState();
}

class _AssignmentsListScreenState extends State<AssignmentsListScreen> {
  _Tab _tab = _Tab.inProgress;

  List<Assignment> _forTab(List<Assignment> all, _Tab tab) {
    return all.where((a) {
      return switch (tab) {
        _Tab.inProgress => a.status == AssignmentStatus.inProgress,
        _Tab.submitted => a.status == AssignmentStatus.submitted,
        _Tab.late => a.status == AssignmentStatus.late,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final all = context.watch<AppState>().assignments;
    final visible = _forTab(all, _tab);

    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('الواجبات', style: tj(20, weight: FontWeight.w800, color: AppColors.textHeading)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _TabButton(label: 'قيد التنفيذ', active: _tab == _Tab.inProgress, onTap: () => setState(() => _tab = _Tab.inProgress)),
                      const SizedBox(width: 16),
                      _TabButton(label: 'مسلمة', active: _tab == _Tab.submitted, onTap: () => setState(() => _tab = _Tab.submitted)),
                      const SizedBox(width: 16),
                      _TabButton(label: 'متأخرة', active: _tab == _Tab.late, onTap: () => setState(() => _tab = _Tab.late)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SectionState(
                section: DemoSection.assignments,
                loading: (context) => const _AssignmentsLoading(),
                empty: (context) => _tab == _Tab.inProgress
                    ? const _AssignmentsEmpty()
                    : Center(child: Text('لا يوجد شيء هنا بعد', style: tj(13, color: AppColors.textFaint))),
                isEmpty: (context) => visible.isEmpty,
                content: (context) => ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _AssignmentCard(assignment: visible[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabButton({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: active ? AppColors.primary : Colors.transparent, width: 2))),
        child: Text(label, style: tj(12, weight: active ? FontWeight.w700 : FontWeight.w400, color: active ? AppColors.primary : AppColors.textFaint)),
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final Assignment assignment;
  const _AssignmentCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final late = assignment.status == AssignmentStatus.late;
    return AppCard(
      border: late ? const Border(right: BorderSide(color: AppColors.coral, width: 3)) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(assignment.title, style: tj(13, weight: FontWeight.w700, color: AppColors.textBody), overflow: TextOverflow.ellipsis),
              ),
              _badge(),
            ],
          ),
          const SizedBox(height: 6),
          Text(assignment.meta, style: tj(11, color: AppColors.textFaint)),
          if (assignment.status == AssignmentStatus.inProgress && assignment.kind == AssignmentKind.quiz) ...[
            const SizedBox(height: 8),
            ProgressTrack(value: assignment.progress),
          ],
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => context.push('/assignment/${assignment.id}'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: late ? AppColors.inputFill : AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(assignment.ctaLabel, style: tj(12, weight: FontWeight.w700, color: late ? AppColors.textMuted : Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  static const _badgePadding = EdgeInsets.symmetric(horizontal: 7, vertical: 4);

  Widget _badge() {
    if (assignment.status == AssignmentStatus.late) {
      return const StatusBadge(label: 'متأخر', fg: AppColors.coral, bg: AppColors.dangerBg, padding: _badgePadding, radius: 6);
    }
    if (assignment.timerLabel != null) {
      return StatusBadge(label: assignment.timerLabel!, fg: AppColors.coral, bg: AppColors.dangerBg, padding: _badgePadding, radius: 6);
    }
    return const StatusBadge(label: 'مفتوح', fg: AppColors.textMuted, bg: AppColors.inputFill, padding: _badgePadding, radius: 6);
  }
}

class _AssignmentsLoading extends StatelessWidget {
  const _AssignmentsLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          Skeleton(height: 100),
          SizedBox(height: 12),
          Skeleton(height: 100),
          SizedBox(height: 12),
          Skeleton(height: 100),
        ],
      ),
    );
  }
}

class _AssignmentsEmpty extends StatelessWidget {
  const _AssignmentsEmpty();

  @override
  Widget build(BuildContext context) {
    return const StateMessage(
      icon: AppIcon(IconBodies.checkCircle, size: 34, color: AppColors.success, strokeWidth: 1.8),
      iconBg: AppColors.successBg,
      title: 'لا واجبات معلقة',
      subtitle: 'أنجزت كل شيء! تحقق لاحقًا من واجبات جديدة',
    );
  }
}
