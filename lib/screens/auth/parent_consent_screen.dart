import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_api.dart';
import '../../services/api_client.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/misc.dart';

class ParentConsentScreen extends StatefulWidget {
  final String? studentId;
  const ParentConsentScreen({super.key, this.studentId});

  @override
  State<ParentConsentScreen> createState() => _ParentConsentScreenState();
}

class _ParentConsentScreenState extends State<ParentConsentScreen> {
  bool _shareResults = true;
  bool _recordSessions = true;
  bool _submitting = false;
  final List<Offset?> _strokePoints = [];

  bool get _signed => _strokePoints.isNotEmpty;

  Future<void> _submit() async {
    if (!_signed) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى التوقيع أولًا لإتمام الموافقة')));
      return;
    }
    final studentId = widget.studentId;
    if (studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر تحديد الطالب المطلوب الموافقة عليه')));
      return;
    }
    setState(() => _submitting = true);
    try {
      await AuthApi.instance.parentConsent(studentId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ موافقة ولي الأمر بنجاح')));
      context.go('/home');
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const BackChevron(),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text('نموذج موافقة ولي الأمر', style: tj(21, weight: FontWeight.w800, color: AppColors.textHeading)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(color: AppColors.tint, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const AvatarPlaceholder(size: 38, photoAsset: 'assets/avatars/lama.png'),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('لمى عبدالله الحربي', style: tj(13, weight: FontWeight.w700, color: AppColors.textBody)),
                                Text('الصف السادس ابتدائي', style: tj(11, color: AppColors.textMuted)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        height: 150,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9FC),
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            'أقرّ أنا ولي أمر الطالبة المذكورة أعلاه بموافقتي الرسمية على مشاركتها في '
                            'برنامج فصول ألف للموهوبين، وأوافق على تسجيل اللقاءات المباشرة لأغراض تعليمية، '
                            'ومشاركة نتائج التقييم مع الجهات المعنية داخل المنصة، وتسجيل بيانات الحضور '
                            'والغياب، والالتزام بالتواصل مع أخصائي الموهبة المتابع لملف ابنتي عند الحاجة، '
                            'مع علمي بإمكانية سحب هذه الموافقة في أي وقت من خلال إعدادات الحساب.',
                            style: tj(11, color: AppColors.textMuted, height: 1.9),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _ConsentCheck(
                        label: 'أوافق على مشاركة النتائج',
                        value: _shareResults,
                        onTap: () => setState(() => _shareResults = !_shareResults),
                      ),
                      const SizedBox(height: 8),
                      _ConsentCheck(
                        label: 'أوافق على تسجيل اللقاءات',
                        value: _recordSessions,
                        onTap: () => setState(() => _recordSessions = !_recordSessions),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onPanUpdate: (d) => setState(() => _strokePoints.add(d.localPosition)),
                        onPanEnd: (_) => setState(() => _strokePoints.add(null)),
                        child: Container(
                          height: 90,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFC7C4EF), width: 1.5, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _signed
                              ? CustomPaint(painter: _SignaturePainter(_strokePoints), size: Size.infinite)
                              : Center(
                                  child: Text('التوقيع الرقمي (ارسم بإصبعك)', style: tj(12, color: AppColors.textFaint)),
                                ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoBox(label: 'الاسم الكامل لولي الأمر', value: 'عبدالله سعد الحربي'),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: _InfoBox(label: 'رقم الهوية', value: '10XXXXXXXX')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                label: _submitting ? 'جارٍ الحفظ...' : 'الموافقة والحفظ',
                padding: const EdgeInsets.symmetric(vertical: 14),
                fontSize: 14,
                onTap: _submitting ? null : _submit,
              ),
              const SizedBox(height: 10),
              OutlineButton(
                label: 'تنزيل نسخة PDF',
                color: AppColors.textMuted,
                fontSize: 13,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تنزيل نسخة PDF'))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConsentCheck extends StatelessWidget {
  final String label;
  final bool value;
  final VoidCallback onTap;
  const _ConsentCheck({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: value ? AppColors.primary : Colors.transparent,
              border: value ? null : Border.all(color: AppColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: tj(11, color: AppColors.textBody)),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  const _InfoBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: tj(9, color: AppColors.textFaint)),
          const SizedBox(height: 2),
          Text(value, style: tj(12, color: AppColors.textBody)),
        ],
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  _SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ink
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
