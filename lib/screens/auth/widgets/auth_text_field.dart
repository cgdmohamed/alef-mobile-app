import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';

/// The filled `#F3F3FB` input used across login/signup/consent forms.
class AuthTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? hint;
  final bool obscure;
  final Widget? trailing;
  final TextInputType? keyboardType;
  final double labelSize;
  final double valueSize;
  final double radius;

  const AuthTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.obscure = false,
    this.trailing,
    this.keyboardType,
    this.labelSize = 12,
    this.valueSize = 14,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: tj(labelSize, weight: FontWeight.w500, color: AppColors.textLabel)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  keyboardType: keyboardType,
                  textAlign: TextAlign.right,
                  style: tj(valueSize, color: AppColors.textBody),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: hint,
                    hintStyle: tj(valueSize, color: AppColors.textDisabled),
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ],
    );
  }
}

/// A compact select-style row (chevron on the left) — stage picker etc.
class AuthSelectField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const AuthSelectField({super.key, required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: tj(11, weight: FontWeight.w500, color: AppColors.textLabel)),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(11),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: tj(13, color: AppColors.textBody)),
                Text('﹀', style: tj(12, color: AppColors.textFaint)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
