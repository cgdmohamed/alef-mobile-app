import 'package:flutter/material.dart';

/// Palette lifted 1:1 from the Claude Design source
/// (`Alef Mobile App.dc.html`) — do not "round" these to
/// Material defaults, the design was built around these exact hexes.
class AppColors {
  AppColors._();

  static const Color ink = Color(0xFF05045E); // headings / primary-dark
  static const Color primary = Color(0xFF4338F2); // brand primary
  static const Color primaryLight = Color(0xFF807FF9); // brand secondary
  static const Color sky = Color(0xFF3FA9F5); // info / attendance accent
  static const Color coral = Color(0xFFFF6B6B); // danger / overdue accent
  static const Color border = Color(0xFFE2E8F0); // hairline / input border
  static const Color mint = Color(0xFF22B07D); // school-code success / live-activity accent
  static const Color mintDark = Color(0xFF12876A); // live-activity gradient end

  static const Color scaffold = Color(0xFFF1F0F9); // gallery bg (unused in-app)
  static const Color screenBg = Color(0xFFF7F7FC); // most screen backgrounds
  static const Color card = Color(0xFFFFFFFF);
  static const Color inputFill = Color(0xFFF3F3FB);
  static const Color tint = Color(0xFFF8F7FF); // subtle brand-tinted panel
  static const Color tintBorder = Color(0xFFE7E6FB);
  static const Color divider = Color(0xFFEEF0F6);

  static const Color textHeading = Color(0xFF05045E);
  static const Color textBody = Color(0xFF1A1840);
  static const Color textLabel = Color(0xFF14123F);
  static const Color textMuted = Color(0xFF6E6B99);
  static const Color textFaint = Color(0xFF8B89B8);
  static const Color textDisabled = Color(0xFFB4B2D6);

  static const Color success = Color(0xFF1E9E5A);
  static const Color successBg = Color(0xFFE9F9EE);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFFF3D6);
  static const Color warningBgSoft = Color(0xFFFFF7E8);
  static const Color warningText = Color(0xFF9A6B14);
  static const Color dangerBg = Color(0xFFFFEDED);
  static const Color dangerBgSoft = Color(0xFFFFF3F0);
  static const Color dangerTextSoft = Color(0xFF9A4A2E);
  static const Color orangeAccent = Color(0xFFC2410C);
  static const Color gold = Color(0xFFFFD98A);

  static const Color notifUnreadBg = Color(0xFFF0EEFE);

  // Live-meeting / video-call dark surfaces
  static const Color liveBg = Color(0xFF0A0930);
  static const Color liveSurface = Color(0xFF151339);
  static const Color liveControl = Color(0xFF232052);
  static const Color liveMuted = Color(0xFF8886B8);
  static const Color liveMuted2 = Color(0xFFB4B2D6);
  static const Color liveAvatarDim = Color(0xFF2A2760);

  static const Color skeletonBase = Color(0xFFEDEDF6);
  static const Color skeletonHighlight = Color(0xFFF5F5FA);

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, ink],
  );

  static const profileHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, ink],
  );

  static const congratsGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, ink],
  );

  static const leaderboardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary],
  );
}
