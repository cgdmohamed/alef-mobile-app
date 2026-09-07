import 'package:flutter/material.dart';

enum UserRole { student, parent }

enum MeetingStatus { liveNow, upcoming, ended }

class Meeting {
  final String id;
  final String title;
  final String teacher;
  final String timeLabel;
  final String group; // اليوم / غدًا / هذا الأسبوع / منتهية
  final MeetingStatus status;
  final String? recordingLength;

  const Meeting({
    required this.id,
    required this.title,
    required this.teacher,
    required this.timeLabel,
    required this.group,
    required this.status,
    this.recordingLength,
  });
}

enum AssignmentKind { quiz, essay, puzzle }

enum AssignmentStatus { inProgress, submitted, late }

class Assignment {
  final String id;
  final String title;
  final AssignmentKind kind;
  final String meta;
  AssignmentStatus status;
  final double progress;
  final String ctaLabel;
  final String? timerLabel;
  final String dueLabel;

  Assignment({
    required this.id,
    required this.title,
    required this.kind,
    required this.meta,
    required this.status,
    this.progress = 0,
    required this.ctaLabel,
    this.timerLabel,
    required this.dueLabel,
  });
}

class AppNotification {
  final String id;
  final String title;
  final String subtitle;
  final String timeLabel;
  final String iconBody;
  final Color iconColor;
  bool read;

  AppNotification({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.iconBody,
    required this.iconColor,
    this.read = false,
  });
}

class SkillScore {
  final String label;
  final int percent;
  final Color color;
  const SkillScore(this.label, this.percent, this.color);
}

class MonthlyReport {
  final String title;
  final String meta;
  const MonthlyReport(this.title, this.meta);
}

class AchievementBadge {
  final String emoji;
  final String label;
  final bool locked;
  const AchievementBadge(this.emoji, this.label, {this.locked = false});
}

class LeaderboardEntry {
  final int rank;
  final String name;
  final int points;
  final Color color;
  const LeaderboardEntry(this.rank, this.name, this.points, this.color);
}

class ChatMessage {
  final String text;
  final bool fromUser;
  const ChatMessage(this.text, {this.fromUser = false});
}
