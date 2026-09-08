import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_api.dart';
import '../../services/api_client.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/buttons.dart';
import 'widgets/auth_text_field.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    final email = _email.text.trim();
    if (email.isEmpty) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await AuthApi.instance.requestOtp(email);
      if (!mounted) return;
      context.push('/forgot-password', extra: {'email': email, 'purpose': OtpPurpose.login});
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Image.asset('assets/branding/logo_mark_color.png', width: 56, height: 56),
              ),
              const SizedBox(height: 22),
              Text('مرحبًا بعودتك', style: tj(26, weight: FontWeight.w800, color: AppColors.textHeading)),
              const SizedBox(height: 6),
              Text('أدخل بريدك الإلكتروني لتسجيل الدخول برمز تحقق', style: tj(14, color: AppColors.textMuted)),
              const SizedBox(height: 24),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.dangerBg, borderRadius: BorderRadius.circular(10)),
                  child: Text(_error!, style: tj(12, color: AppColors.coral)),
                ),
                const SizedBox(height: 14),
              ],
              AuthTextField(
                label: 'البريد الإلكتروني',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: _sending ? 'جارٍ الإرسال...' : 'إرسال رمز التحقق',
                onTap: _sending ? null : _requestOtp,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.border, height: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('أو', style: tj(12, color: AppColors.textFaint)),
                  ),
                  const Expanded(child: Divider(color: AppColors.border, height: 1)),
                ],
              ),
              const SizedBox(height: 22),
              OutlineButton(label: 'تواصل مع خدمة العملاء', onTap: () => context.push('/support')),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => context.push('/signup'),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: tj(13, color: AppColors.textMuted),
                    children: [
                      const TextSpan(text: 'ليس لديك حساب؟ '),
                      TextSpan(text: 'سجل الآن', style: tj(13, weight: FontWeight.w700, color: AppColors.primary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
