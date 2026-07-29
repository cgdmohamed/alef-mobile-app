import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Solid brand button — `background:#4338F2` pill used for every primary
/// CTA in the design (login, submit, join meeting, ...).
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool shadow;
  final double radius;
  final EdgeInsets padding;
  final double fontSize;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.shadow = true,
    this.radius = 14,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.fontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: onTap == null ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: shadow
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(label, style: tj(fontSize, weight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    );
  }
}

/// Outlined brand button — `border:1.5px solid #4338F2` secondary action.
class OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final double radius;
  final EdgeInsets padding;
  final double fontSize;

  const OutlineButton({
    super.key,
    required this.label,
    this.onTap,
    this.color = AppColors.primary,
    this.radius = 14,
    this.padding = const EdgeInsets.symmetric(vertical: 14),
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 1.5),
            borderRadius: BorderRadius.circular(radius),
          ),
          alignment: Alignment.center,
          child: Text(label, style: tj(fontSize, weight: FontWeight.w600, color: color)),
        ),
      ),
    );
  }
}

/// Small pill chip button — used for filter chips, tags, quick replies.
class PillChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;
  final Widget? icon;
  final double fontSize;
  final EdgeInsets padding;

  const PillChip({
    super.key,
    required this.label,
    this.active = false,
    this.onTap,
    this.icon,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.inputFill,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 4)],
              Text(
                label,
                style: tj(fontSize, weight: FontWeight.w600, color: active ? Colors.white : AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
