import 'package:flutter/material.dart';

/// Thin wrapper so every text style in the app goes through Tajawal with
/// the same shorthand the design file used (`font: weight size/line Tajawal`).
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
    fontSize: size,
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
