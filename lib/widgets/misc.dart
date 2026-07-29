import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// White rounded card — the base surface reused across nearly every screen.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color color;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 14,
    this.color = AppColors.card,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: border,
      ),
      child: child,
    );
  }
}

/// One of the 4 KPI tiles on the home dashboards (`3 / واجبات معلقة`, etc).
class StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  final double valueSize;
  final double labelSize;

  const StatTile({
    super.key,
    required this.value,
    required this.label,
    required this.valueColor,
    this.valueSize = 18,
    this.labelSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: tj(valueSize, weight: FontWeight.w800, color: valueColor)),
          const SizedBox(height: 2),
          Text(label, style: tj(labelSize, color: AppColors.textFaint), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// Thin rounded progress track — assignment %, skill bars, quiz progress.
class ProgressTrack extends StatelessWidget {
  final double value; // 0..1
  final Color color;
  final double height;
  final Color trackColor;

  const ProgressTrack({
    super.key,
    required this.value,
    this.color = AppColors.primary,
    this.height = 5,
    this.trackColor = AppColors.border,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(height: height, color: trackColor),
              Align(
                alignment: Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: value.clamp(0, 1),
                  child: Container(height: height, color: color),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A labelled skill/progress row: `التفكير النقدي  88%` + bar underneath.
class LabeledProgress extends StatelessWidget {
  final String label;
  final int percent;
  final Color color;
  final double labelSize;
  final double trackHeight;
  final double gap;

  const LabeledProgress({
    super.key,
    required this.label,
    required this.percent,
    required this.color,
    this.labelSize = 10,
    this.trackHeight = 5,
    this.gap = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: gap),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: tj(labelSize, color: AppColors.textMuted)),
              Text('$percent%', style: tj(labelSize, color: AppColors.textMuted)),
            ],
          ),
        ),
        ProgressTrack(value: percent / 100, color: color, height: trackHeight),
      ],
    );
  }
}

/// Status pill — `مباشر الآن`, `قادم`, `متأخر`, `ممتاز`, ...
class StatusBadge extends StatelessWidget {
  final String label;
  final Color fg;
  final Color bg;
  final double fontSize;
  final EdgeInsets padding;
  final double radius;

  const StatusBadge({
    super.key,
    required this.label,
    required this.fg,
    required this.bg,
    this.fontSize = 9,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.radius = 7,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(radius)),
      child: Text(label, style: tj(fontSize, weight: FontWeight.w700, color: fg)),
    );
  }
}

/// A shimmering placeholder block used by every `*-loading` screen state.
class Skeleton extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;

  const Skeleton({super.key, this.width, required this.height, this.radius = 14});

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * t, 0),
              end: Alignment(1 + 2 * t, 0),
              colors: const [
                AppColors.skeletonBase,
                AppColors.skeletonHighlight,
                AppColors.skeletonBase,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Circle-badge "avatar" placeholder — stands in for `<image-slot>` /
/// unfilled photo slots in the source design (flat brand-tint circle).
class AvatarPlaceholder extends StatelessWidget {
  final double size;
  final Color color;
  const AvatarPlaceholder({super.key, this.size = 40, this.color = AppColors.primaryLight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// A generic full-screen empty/error placeholder (icon + title + subtitle
/// + optional CTA) matching the `*-فارغة` / `*-خطأ` design states.
class StateMessage extends StatelessWidget {
  final Widget icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const StateMessage({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: icon,
            ),
            const SizedBox(height: 16),
            Text(title, style: tj(17, weight: FontWeight.w800, color: AppColors.textHeading)),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: tj(12, color: AppColors.textFaint, height: 1.7),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 14),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(actionLabel!, style: tj(12, weight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Section title with the small vertical accent bar (`المصادقة والتسجيل`
/// style headers), reused for in-screen section headings.
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: tj(13, weight: FontWeight.w700, color: AppColors.textHeading));
  }
}

/// Back-chevron used throughout the design as a literal `›` glyph
/// (mirrors correctly for RTL without needing a mirrored icon asset).
class BackChevron extends StatelessWidget {
  final VoidCallback? onTap;
  const BackChevron({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Text('›', style: tj(20, color: AppColors.textHeading)),
      ),
    );
  }
}

/// Toggle switch matching the design's custom pill switch (not the Material
/// default), used across Settings / Sign up.
class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  const AppSwitch({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 38,
        height: 22,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.border,
          borderRadius: BorderRadius.circular(11),
        ),
        alignment: value ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
