import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/buttons.dart';
import 'widgets/auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController(text: 'sara.ahmed@email.com');
  final _password = TextEditingController(text: '••••••••••');
  bool _obscure = true;
  bool _rememberMe = true;
  UserRole _role = UserRole.student;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    context.read<AppState>().setRole(_role);
    context.go('/home');
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
              Text('سجّل دخولك لمتابعة رحلتك التعليمية', style: tj(14, color: AppColors.textMuted)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _RoleTab(label: 'طالب', selected: _role == UserRole.student, onTap: () => setState(() => _role = UserRole.student))),
                  const SizedBox(width: 10),
                  Expanded(child: _RoleTab(label: 'ولي أمر', selected: _role == UserRole.parent, onTap: () => setState(() => _role = UserRole.parent))),
                ],
              ),
              const SizedBox(height: 20),
              AuthTextField(label: 'البريد الإلكتروني', controller: _email),
              const SizedBox(height: 14),
              AuthTextField(
                label: 'كلمة السر',
                controller: _password,
                obscure: _obscure,
                trailing: GestureDetector(
                  onTap: () => setState(() => _obscure = !_obscure),
                  child: Text(_obscure ? 'إظهار' : 'إخفاء', style: tj(12, color: AppColors.primary)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _rememberMe = !_rememberMe),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: _rememberMe ? AppColors.primary : Colors.transparent,
                            border: _rememberMe ? null : Border.all(color: AppColors.border, width: 1.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('تذكرني', style: tj(12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/forgot-password'),
                    child: Text('نسيت كلمة السر؟', style: tj(12, weight: FontWeight.w500, color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              PrimaryButton(label: 'تسجيل الدخول', onTap: _login),
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

class _RoleTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RoleTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.inputFill,
          borderRadius: BorderRadius.circular(11),
        ),
        alignment: Alignment.center,
        child: Text(label, style: tj(12, weight: FontWeight.w700, color: selected ? Colors.white : AppColors.textMuted)),
      ),
    );
  }
}
