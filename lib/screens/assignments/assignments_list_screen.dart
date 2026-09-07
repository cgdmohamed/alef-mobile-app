import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/assignments_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/misc.dart';

enum _Tab { inProgress, submitted, late }

class AssignmentsListScreen extends StatefulWidget {
  const AssignmentsListScreen({super.key});

  @override
  State<AssignmentsListScreen> createState() => _AssignmentsListScreenState();
}

class _AssignmentsListScreenState extends State<AssignmentsListScreen> {
  _Tab _tab = _Tab.inProgress;
  bool _loading = true;
  String? _error;
  List<ApiAssignment> _all = [];

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
      final data = await AssignmentsApi.instance.myAssignments();
      if (!mounted) return;
      setState(() {
        _all = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'تعذر تحميل الواجبات';
        _loading = false;
      });
    }
  }

  List<ApiAssignment> _forTab(List<ApiAssignment> all, _Tab tab) {
    return all.where((a) {
      return switch (tab) {
        _Tab.inProgress => a.submissionStatus == null || a.submissionStatus == 'in_progress',
        _Tab.submitted => a.submissionStatus == 'submitted' || a.submissionStatus == 'graded',
        _Tab.late => a.submissionStatus == 'late',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _forTab(_all, _tab);

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
              child: _loading
                  ? const _AssignmentsLoading()
                  : _error != null
                      ? StateMessage(
                          icon: Text('!', style: tj(40, color: AppColors.coral)),
                          iconBg: AppColors.dangerBg,
                          title: 'تعذر تحميل الواجبات',
                          subtitle: 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى',
                          actionLabel: 'إعادة المحاولة',
                          onAction: _load,
                        )
                      : visible.isEmpty
                          ? (_tab == _Tab.inProgress
                              ? const _AssignmentsEmpty()
                              : Center(child: Text('لا يوجد شيء هنا بعد', style: tj(13, color: AppColors.textFaint))))
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                              itemCount: visible.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 12),
                              itemBuilder: (context, i) => _AssignmentCard(assignment: visible[i]),
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
  final ApiAssignment assignment;
  const _AssignmentCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final late = assignment.submissionStatus == 'late';
    final submitted = assignment.submissionStatus == 'submitted' || assignment.submissionStatus == 'graded';
    final secondaryStyle = late || submitted;
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
          Text('يستحق ${assignment.dueAt.day}/${assignment.dueAt.month}', style: tj(11, color: AppColors.textFaint)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => context.push(
              submitted ? '/assignment/${assignment.id}/result' : '/assignment/${assignment.id}',
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: secondaryStyle ? AppColors.inputFill : AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                submitted ? 'عرض النتيجة' : (late ? 'تسليم متأخر' : 'ابدأ الآن'),
                style: tj(12, weight: FontWeight.w700, color: secondaryStyle ? AppColors.textMuted : Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _badgePadding = EdgeInsets.symmetric(horizontal: 7, vertical: 4);

  Widget _badge() {
    if (assignment.submissionStatus == 'late') {
      return const StatusBadge(label: 'متأخر', fg: AppColors.coral, bg: AppColors.dangerBg, padding: _badgePadding, radius: 6);
    }
    if (assignment.submissionStatus == 'submitted' || assignment.submissionStatus == 'graded') {
      return const StatusBadge(label: 'تم التسليم', fg: AppColors.success, bg: AppColors.successBg, padding: _badgePadding, radius: 6);
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
