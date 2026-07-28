import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Line-icon set traced 1:1 from the inline `<svg>` markup in the source
/// design (`Alef Mobile App.dc.html`). Each body is the raw set of
/// `<path>`/`<rect>`/`<circle>` children on a `0 0 24 24` canvas; colour is
/// applied at render time via [ColorFilter] so one body serves every
/// active/inactive/dark-surface variant seen in the design.
class IconBodies {
  IconBodies._();

  static const lock =
      '<rect x="5" y="11" width="14" height="9" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/>';
  static const bell =
      '<path d="M6 8a6 6 0 0 1 12 0c0 5 2 6 2 6H4s2-1 2-6"/><path d="M10 20a2 2 0 0 0 4 0"/>';
  static const bellSimple = '<path d="M6 8a6 6 0 0 1 12 0c0 5 2 6 2 6H4s2-1 2-6"/>';
  static const clock = '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>';
  static const home =
      '<path d="M4 11l8-7 8 7v9a1 1 0 0 1-1 1h-4v-6H9v6H5a1 1 0 0 1-1-1z"/>';
  static const docFold = '<path d="M6 4h9l3 3v13H6z"/><path d="M15 4v3h3"/>';
  static const calendar =
      '<rect x="4" y="6" width="16" height="14" rx="2"/><path d="M4 10h16M8 4v4M16 4v4"/>';
  static const bars = '<path d="M5 20V10M12 20V4M19 20v-7"/>';
  static const person =
      '<circle cx="12" cy="8" r="4"/><path d="M4 20c0-4 4-6 8-6s8 2 8 6"/>';
  static const search =
      '<circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/>';
  static const list =
      '<path d="M8 6h13M8 12h13M8 18h13M3 6h.01M3 12h.01M3 18h.01"/>';
  static const mic =
      '<rect x="9" y="3" width="6" height="11" rx="3"/><path d="M5 11a7 7 0 0 0 14 0M12 18v3"/>';
  static const camera =
      '<rect x="3" y="6" width="13" height="12" rx="2"/><path d="M16 10l5-3v10l-5-3"/>';
  static const arrowUp = '<path d="M12 19V6M7 10l5-5 5 5"/>';
  static const chat = '<path d="M4 5h16v11H8l-4 4z"/>';
  static const rewind = '<path d="M11 19l-8-7 8-7M20 19l-8-7 8-7"/>';
  static const playFilled = '<path d="M8 5v14l11-7z"/>';
  static const forward = '<path d="M13 5l8 7-8 7M4 5l8 7-8 7"/>';
  static const fullscreen =
      '<path d="M8 3H5a2 2 0 00-2 2v3M16 3h3a2 2 0 012 2v3M8 21H5a2 2 0 01-2-2v-3M16 21h3a2 2 0 002-2v-3"/>';
  static const starFilled =
      '<path d="M12 2l2.9 6.6 7.1.6-5.4 4.7 1.6 7-6.2-3.8-6.2 3.8 1.6-7L2 9.2l7.1-.6z"/>';
  static const pencil =
      '<path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 013 3L7 19l-4 1 1-4z"/>';
  static const shield =
      '<path d="M12 3l7 3v6c0 4.5-3 7.5-7 9-4-1.5-7-4.5-7-9V6z"/>';
  static const checkCircle =
      '<circle cx="12" cy="12" r="9"/><path d="M8 12l2.5 2.5L16 9"/>';
  static const image =
      '<rect x="3" y="4" width="18" height="16" rx="2"/><circle cx="8.5" cy="9.5" r="1.5"/><path d="M21 15l-5-5L5 20"/>';
  static const paperclip =
      '<path d="M8 12l7-7a3.5 3.5 0 015 5l-9 9a2 2 0 01-3-3l8-8"/>';
  static const gear =
      '<circle cx="12" cy="12" r="3"/><path d="M19 12a7 7 0 000-.5l1.6-1.3-1.6-2.8-2 .6a7 7 0 00-1.7-1L15 4h-3l-.3 2a7 7 0 00-1.7 1l-2-.6L6.4 9.2 8 10.5a7 7 0 000 1L6.4 12.8 8 15.6l2-.6a7 7 0 001.7 1l.3 2h3l.3-2a7 7 0 001.7-1l2 .6 1.6-2.8L19 12z"/>';
  static const docLines = '<path d="M6 3h9l3 3v15H6z"/><path d="M9 12h6M9 16h6"/>';
  static const medal =
      '<circle cx="12" cy="9" r="5"/><path d="M9 13.5L7 22l5-3 5 3-2-8.5"/>';
  static const logout =
      '<path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/><path d="M16 17l5-5-5-5M21 12H9"/>';
  static const send = '<path d="M3 11l18-8-8 18-2-8z"/>';
  static const closeX =
      '<path d="M6 6l12 12M18 6L6 18" stroke-linecap="round"/>';
  static const pauseFilled =
      '<rect x="6" y="5" width="4" height="14" rx="1"/><rect x="14" y="5" width="4" height="14" rx="1"/>';
}

/// Renders an [IconBodies] entry as crisp vector art at any size/color.
class AppIcon extends StatelessWidget {
  final String body;
  final double size;
  final Color color;
  final double strokeWidth;
  final bool filled;

  const AppIcon(
    this.body, {
    super.key,
    this.size = 20,
    required this.color,
    this.strokeWidth = 1.8,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final svg = filled
        ? '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#000" stroke="none">$body</svg>'
        : '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#000" stroke-width="$strokeWidth">$body</svg>';
    return SvgPicture.string(
      svg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
