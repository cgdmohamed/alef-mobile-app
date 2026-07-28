import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/misc.dart';

class AssignmentResultScreen extends StatefulWidget {
  final String assignmentId;
  const AssignmentResultScreen({super.key, required this.assignmentId});

  @override
  State<AssignmentResultScreen> createState() => _AssignmentResultScreenState();
}

class _AssignmentResultScreenState extends State<AssignmentResultScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AppState>().completeAssignment(widget.assignmentId);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) showDialog(context: context, barrierDismissible: true, builder: (_) => const _CongratsModal());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    children: [
                      _ScoreRing(percent: 0.92),
                      SizedBox(height: 10),
                      StatusBadge(label: 'ممتاز', fg: AppColors.success, bg: AppColors.successBg),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              AppCard(
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      style: tj(11, color: AppColors.textMuted),
                      children: [
                        const TextSpan(text: 'متوسط الفصل: '),
                        TextSpan(text: '78%', style: tj(11, weight: FontWeight.w700, color: AppColors.textHeading)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ملاحظات المدرب', style: tj(12, weight: FontWeight.w700, color: AppColors.textHeading)),
                    const SizedBox(height: 6),
                    Text('أداء ممتاز! ركزي أكثر على مسائل الكسور المركبة', style: tj(11, color: AppColors.textMuted, height: 1.7)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              AppCard(
                child: Column(
                  children: const [
                    _QuestionRow(label: 'السؤال 1', correct: true),
                    SizedBox(height: 8),
                    _QuestionRow(label: 'السؤال 2', correct: false),
                    SizedBox(height: 8),
                    _QuestionRow(label: 'السؤال 3', correct: true),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlineButton(
                      label: 'عرض الواجب',
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      fontSize: 12,
                      onTap: () => context.go('/assignments'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PrimaryButton(
                      label: 'مشاركة',
                      shadow: false,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      fontSize: 12,
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت مشاركة النتيجة'))),
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

class _QuestionRow extends StatelessWidget {
  final String label;
  final bool correct;
  const _QuestionRow({required this.label, required this.correct});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: tj(11, color: AppColors.textBody)),
        Text(
          correct ? '✓ صحيح' : '✕ خطأ',
          style: tj(11, color: correct ? AppColors.success : AppColors.coral),
        ),
      ],
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
  const _CongratsModal();

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
              'حصلت على تقييم ممتاز في اختبار الرياضيات — استمري بهذا التميز',
              textAlign: TextAlign.center,
              style: tj(14, color: const Color(0xFFDEDCF9), height: 1.7),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(12)),
              child: Text('🏅 شارة جديدة: نجم الرياضيات', style: tj(12, weight: FontWeight.w600, color: AppColors.gold)),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت مشاركة الإنجاز'))),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                alignment: Alignment.center,
                child: Text('مشاركة الإنجاز', style: tj(14, weight: FontWeight.w700, color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Text('إغلاق', style: tj(12, color: const Color(0xFFB4B2D6))),
            ),
          ],
        ),
      ),
    );
  }
}
