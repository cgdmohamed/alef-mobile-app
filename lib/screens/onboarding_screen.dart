import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/buttons.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => context.go('/login'),
                  child: Text('تخطي', style: tj(14, weight: FontWeight.w500, color: AppColors.textFaint)),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.school_rounded, size: 110, color: AppColors.primary),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'تعلّم مع أفضل المدربين',
                      style: tj(22, weight: FontWeight.w800, color: AppColors.textHeading),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'مدربون متخصصون في رعاية الطلبة الموهوبين ومتابعتهم عن قرب',
                      textAlign: TextAlign.center,
                      style: tj(14, color: AppColors.textMuted, height: 1.7),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 22,
                        height: 8,
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                      ),
                      const SizedBox(width: 8),
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.border, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.border, shape: BoxShape.circle)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(label: 'التالي', onTap: () => context.go('/login')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
