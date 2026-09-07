import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_api.dart';
import '../../services/api_client.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/misc.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/step_indicator.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _studentName = TextEditingController(text: 'لمى عبدالله الحربي');
  final _phone = TextEditingController();
  final _parentName = TextEditingController(text: 'عبدالله الحربي');
  final _parentEmail = TextEditingController(text: 'abdullah.h@email.com');
  bool _mawhibaRegistered = true;
  bool _agreed = true;
  bool _submitting = false;
  String? _error;
  static const _stages = ['الصف الرابع ابتدائي', 'الصف الخامس ابتدائي', 'الصف السادس ابتدائي', 'الأول متوسط', 'الثاني متوسط'];
  String _stage = 'الصف السادس ابتدائي';

  @override
  void dispose() {
    _studentName.dispose();
    _phone.dispose();
    _parentName.dispose();
    _parentEmail.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_agreed || _submitting) return;
    final phone = _phone.text.trim();
    if (phone.isEmpty) {
      setState(() => _error = 'يرجى إدخال رقم جوال ولي الأمر');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await AuthApi.instance.signup(name: _studentName.text.trim(), phone: phone, role: 'student');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنشاء الحساب، يرجى تسجيل الدخول برقم الجوال لإتمام موافقة ولي الأمر')),
      );
      context.go('/login');
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _pickStage() async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _stages
              .map((s) => ListTile(
                    title: Text(s, textAlign: TextAlign.right, style: tj(14, color: AppColors.textBody)),
                    onTap: () => Navigator.pop(context, s),
                  ))
              .toList(),
        ),
      ),
    );
    if (chosen != null) setState(() => _stage = chosen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const BackChevron(),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'انضم إلى ألف المستقبل',
                      style: tj(22, weight: FontWeight.w800, color: AppColors.textHeading),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const StepIndicator(step: 2),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.tint,
                  border: Border.all(color: AppColors.tintBorder),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(color: AppColors.mint, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text('✓', style: tj(8, weight: FontWeight.w700, color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'مدارس الرواد · المفكر الناقد الصغير · السادس/أ',
                        style: tj(11, weight: FontWeight.w600, color: AppColors.ink),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('بيانات الطالب', style: tj(20, weight: FontWeight.w800, color: AppColors.textHeading)),
              const SizedBox(height: 16),
              AuthTextField(label: 'اسم الطالب الثلاثي', controller: _studentName, labelSize: 11, valueSize: 13, radius: 11),
              const SizedBox(height: 12),
              AuthTextField(
                label: 'رقم جوال ولي الأمر',
                controller: _phone,
                keyboardType: TextInputType.phone,
                labelSize: 11,
                valueSize: 13,
                radius: 11,
              ),
              const SizedBox(height: 12),
              AuthSelectField(label: 'المرحلة الدراسية', value: _stage, onTap: _pickStage),
              const SizedBox(height: 12),
              AuthTextField(label: 'اسم ولي الأمر', controller: _parentName, labelSize: 11, valueSize: 13, radius: 11),
              const SizedBox(height: 12),
              AuthTextField(
                label: 'بريد ولي الأمر',
                controller: _parentEmail,
                keyboardType: TextInputType.emailAddress,
                labelSize: 11,
                valueSize: 13,
                radius: 11,
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.tint,
                  border: Border.all(color: AppColors.tintBorder),
                  borderRadius: BorderRadius.circular(11),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('هل سبق التسجيل في مقياس موهبة؟', style: tj(12, color: AppColors.textBody)),
                    ),
                    AppSwitch(value: _mawhibaRegistered, onChanged: (v) => setState(() => _mawhibaRegistered = v)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => setState(() => _agreed = !_agreed),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 15,
                        height: 15,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: _agreed ? AppColors.primary : Colors.transparent,
                          border: _agreed ? null : Border.all(color: AppColors.border, width: 1.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: tj(11, color: AppColors.textMuted, height: 1.6),
                            children: [
                              const TextSpan(text: 'أوافق على '),
                              TextSpan(text: 'الشروط والأحكام', style: tj(11, color: AppColors.primary, height: 1.6)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.dangerBg, borderRadius: BorderRadius.circular(10)),
                  child: Text(_error!, style: tj(12, color: AppColors.coral)),
                ),
              ],
              const SizedBox(height: 28),
              PrimaryButton(
                label: _submitting ? 'جارٍ الإنشاء...' : 'إنشاء الحساب',
                onTap: (_agreed && !_submitting) ? _submit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
