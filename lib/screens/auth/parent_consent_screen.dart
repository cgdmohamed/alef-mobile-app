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
  final String? studentName;
  final String? studentStage;
  const ParentConsentScreen({super.key, this.studentId, this.studentName, this.studentStage});

  @override
  State<ParentConsentScreen> createState() => _ParentConsentScreenState();
}

class _ParentConsentScreenState extends State<ParentConsentScreen> {
  bool _agreed = false;
  bool _submitting = false;

  Future<void> _submit() async {
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى تأكيد الموافقة أولًا')));
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
      context.pop(true);
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
                            const AvatarPlaceholder(size: 38),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.studentName ?? 'الطالب', style: tj(13, weight: FontWeight.w700, color: AppColors.textBody)),
                                Text(widget.studentStage ?? '', style: tj(11, color: AppColors.textMuted)),
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
                            'أقرّ أنا ولي أمر الطالب/الطالبة المذكور أعلاه بموافقتي الرسمية على المشاركة في '
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
                        label: 'قرأت الإقرار وأوافق عليه',
                        value: _agreed,
                        onTap: () => setState(() => _agreed = !_agreed),
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
