import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/buttons.dart';

class AwaitingConsentScreen extends StatefulWidget {
  const AwaitingConsentScreen({super.key});

  @override
  State<AwaitingConsentScreen> createState() => _AwaitingConsentScreenState();
}

class _AwaitingConsentScreenState extends State<AwaitingConsentScreen> {
  bool _checking = false;

  Future<void> _check() async {
    setState(() => _checking = true);
    try {
      await context.read<AppState>().refreshCurrentUser();
      if (!mounted) return;
      if (!context.read<AppState>().isPendingConsent) context.go('/home');
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر التحقق الآن. حاول مرة أخرى')));
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.family_restroom, size: 72, color: AppColors.primary),
              const SizedBox(height: 20),
              Text('بانتظار موافقة ولي الأمر', textAlign: TextAlign.center, style: tj(22, weight: FontWeight.w800, color: AppColors.textHeading)),
              const SizedBox(height: 10),
              Text('يجب أن يسجل ولي الأمر الدخول ببريده ويوافق على الحساب قبل بدء استخدام المنصة.', textAlign: TextAlign.center, style: tj(13, color: AppColors.textMuted, height: 1.8)),
              const SizedBox(height: 28),
              PrimaryButton(label: _checking ? 'جارٍ التحقق...' : 'تحقق من الموافقة', onTap: _checking ? null : _check),
              const SizedBox(height: 12),
              OutlineButton(
                label: 'تسجيل الخروج',
                onTap: () async {
                  await context.read<AppState>().logout();
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
