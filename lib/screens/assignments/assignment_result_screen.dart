import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/assignments_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/buttons.dart';
import '../../widgets/misc.dart';

class AssignmentResultScreen extends StatefulWidget {
  final String assignmentId;
  const AssignmentResultScreen({super.key, required this.assignmentId});

  @override
  State<AssignmentResultScreen> createState() => _AssignmentResultScreenState();
}

class _AssignmentResultScreenState extends State<AssignmentResultScreen> {
  bool _loading = true;
  ApiAssignmentResult? _result;
  bool _showedCongrats = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await AssignmentsApi.instance.result(widget.assignmentId);
    if (!mounted) return;
    setState(() {
      _result = result;
      _loading = false;
    });
    if (result != null && !_showedCongrats) {
      _showedCongrats = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) showDialog(context: context, barrierDismissible: true, builder: (_) => _CongratsModal(grade: result.grade));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(backgroundColor: AppColors.screenBg, body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }

    final result = _result;
    if (result == null) {
      return Scaffold(
        backgroundColor: AppColors.screenBg,
        body: SafeArea(
          child: StateMessage(
            icon: const AppIcon(IconBodies.clock, size: 34, color: AppColors.primary, strokeWidth: 1.6),
            iconBg: AppColors.inputFill,
            title: 'لم يتم تصحيح الواجب بعد',
            subtitle: 'سيقوم المعلم بتصحيح إجاباتك قريبًا، تحقق لاحقًا',
            actionLabel: 'عرض الواجبات',
            onAction: () => context.go('/assignments'),
          ),
        ),
      );
    }

    final grade = result.grade;
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (grade != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      children: [
                        _ScoreRing(percent: (grade / 100).clamp(0, 1)),
                        const SizedBox(height: 10),
                        StatusBadge(
                          label: grade >= 90 ? 'ممتاز' : (grade >= 70 ? 'جيد جدًا' : 'بحاجة لمراجعة'),
                          fg: grade >= 70 ? AppColors.success : AppColors.warning,
                          bg: grade >= 70 ? AppColors.successBg : AppColors.warningBg,
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          radius: 9,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 14),
              if (result.teacherNote != null)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ملاحظات المدرب', style: tj(12, weight: FontWeight.w700, color: AppColors.textHeading)),
                      const SizedBox(height: 6),
                      Text(result.teacherNote!, style: tj(11, color: AppColors.textMuted, height: 1.7)),
                    ],
                  ),
                ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlineButton(
                      label: 'عرض الواجبات',
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      fontSize: 12,
                      onTap: () => context.go('/assignments'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  final double percent;
  const _ScoreRing({required this.percent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: CustomPaint(
        painter: _RingPainter(percent),
        child: Center(
          child: Text('${(percent * 100).round()}%', style: tj(24, weight: FontWeight.w800, color: AppColors.textHeading)),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  _RingPainter(this.percent);

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 12.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.width - strokeWidth) / 2;

    final bg = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bg);

    final fg = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -1.5708, 6.2832 * percent, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.percent != percent;
}

class _CongratsModal extends StatelessWidget {
  final int? grade;
  const _CongratsModal({required this.grade});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
        decoration: BoxDecoration(gradient: AppColors.congratsGradient, borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const Text('🏆', style: TextStyle(fontSize: 52)),
            ),
            const SizedBox(height: 18),
            Text('مبروك!', style: tj(28, weight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 14),
            Text(
              grade != null ? 'حصلت على $grade% في هذا الواجب — استمري بهذا التميز' : 'تم تصحيح واجبك — استمري بهذا التميز',
              textAlign: TextAlign.center,
              style: tj(14, color: const Color(0xFFDEDCF9), height: 1.7),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                alignment: Alignment.center,
                child: Text('إغلاق', style: tj(14, weight: FontWeight.w700, color: AppColors.primary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
