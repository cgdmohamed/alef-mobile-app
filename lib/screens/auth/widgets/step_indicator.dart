import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';

/// The 2-segment "الخطوة N من 2" bar shared by the school-code and
/// student-details steps of signup.
class StepIndicator extends StatelessWidget {
  final int step; // 1 or 2
  const StepIndicator({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _segment(filled: true),
        const SizedBox(width: 8),
        _segment(filled: step >= 2),
        const Spacer(),
        Text('الخطوة $step من 2', style: tj(11, weight: FontWeight.w600, color: AppColors.textFaint)),
      ],
    );
  }

  Widget _segment({required bool filled}) {
    return Container(
      width: 34,
      height: 5,
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
