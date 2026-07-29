import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/branding/logo_mark_white.png',
                  width: 104,
                  height: 104,
                ),
                const SizedBox(height: 22),
                Text('ألف المستقبل', style: tj(30, weight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 6),
                Text('للموهوبين والمتميزين', style: tj(15, color: const Color(0xFFB9B8E8))),
                const SizedBox(height: 18),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: i == 0 ? 0.9 : 0.5),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: Center(
              child: Text('الإصدار 2.4.0', style: tj(11, color: const Color(0xFF7472B8))),
            ),
          ),
        ],
      ),
    );
  }
}
