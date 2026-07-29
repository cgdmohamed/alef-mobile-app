import 'package:flutter/material.dart';

/// The source design was traced at literal CSS pixel sizes (many as small
/// as 8-10px), which reads fine zoomed into a design tool but is genuinely
/// hard to read at native mobile scale. This maps every size used in the
/// design to a slightly larger, evenly-graduated scale — never below 12px,
/// with modest (+2..+4) bumps that taper off for the already-large display
/// sizes — while preserving the same relative hierarchy between them.
final Map<double, double> _readableScale = {
  8: 12,
  9: 12,
  10: 13,
  11: 13,
  12: 14,
  13: 15,
  14: 16,
  15: 17,
  16: 18,
  17: 19,
  18: 20,
  19: 21,
  20: 22,
  21: 23,
  22: 24,
  24: 26,
  26: 28,
  28: 30,
  30: 32,
  34: 36,
  40: 42,
  44: 46,
  52: 54,
};

double scaledFontSize(double size) => _readableScale[size] ?? (size + 2);

/// Thin wrapper so every text style in the app goes through Tajawal with
/// the same shorthand the design file used (`font: weight size/line Tajawal`),
/// scaled up to a readable size via [scaledFontSize].
TextStyle tj(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color? color,
  double? height,
  double? letterSpacing,
  TextDecoration? decoration,
}) {
  return TextStyle(
    fontFamily: 'Tajawal',
    fontSize: scaledFontSize(size),
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
    decoration: decoration,
  );
}

extension FontWeights on FontWeight {
  static const w400 = FontWeight.w400;
  static const w500 = FontWeight.w500;
  static const w600 = FontWeight.w600;
  static const w700 = FontWeight.w700;
  static const w800 = FontWeight.w800;
  static const w900 = FontWeight.w900;
}
