import '../models/models.dart';
import '../theme/app_colors.dart';
import '../widgets/app_icon.dart';

/// Static sample content lifted from the design's own placeholder copy
/// ("لمى عبدالله الحربي", "أ. سلطان العتيبي", ...) so the running app reads
/// exactly like the mockups it was built from.
class MockData {
  MockData._();

  static List<Meeting> meetings() => [
        const Meeting(
          id: 'm1',
          title: 'أساسيات الهندسة الإبداعية',
          teacher: 'أ. سلطان العتيبي',
          timeLabel: '5:00 م',
          group: 'اليوم',
          status: MeetingStatus.liveNow,
        ),
        const Meeting(
          id: 'm2',
          title: 'ورشة الروبوتات',
          teacher: 'أ. نورة القحطاني',
          timeLabel: '4:00 م',
          group: 'غدًا',
          status: MeetingStatus.upcoming,
        ),
        const Meeting(
          id: 'm3',
          title: 'نادي القراءة الأسبوعي',
          teacher: 'أ. منيرة السالم',
          timeLabel: 'الخميس 6:00 م',
          group: 'هذا الأسبوع',
          status: MeetingStatus.upcoming,
        ),
        const Meeting(
          id: 'm4',
          title: 'القراءة النقدية',
          teacher: 'أ. سلطان العتيبي',
          timeLabel: 'أمس',
          group: 'منتهية',
          status: MeetingStatus.ended,
          recordingLength: '38:05',
        ),
      ];

  static List<Assignment> assignments() => [
        Assignment(
          id: 'a1',
          title: 'اختبار الرياضيات — الوحدة 4',
          kind: AssignmentKind.quiz,
          meta: '10 أسئلة • 30 دقيقة • يسلّم غدًا',
          status: AssignmentStatus.inProgress,
          progress: 0.4,
          ctaLabel: 'أكمل',
          timerLabel: '00:32:10',
        ),
        Assignment(
          id: 'a2',
          title: 'تقرير مشروع العلوم',
          kind: AssignmentKind.essay,
          meta: 'مقالي • 300 كلمة • 3 أيام متبقية',
          status: AssignmentStatus.inProgress,
          ctaLabel: 'ابدأ',
        ),
        Assignment(
          id: 'a3',
          title: 'لغز الأشكال المنطقية',
          kind: AssignmentKind.puzzle,
          meta: 'لغز إبداعي • انتهى أمس',
          status: AssignmentStatus.late,
          ctaLabel: 'سلّم متأخرًا',
        ),
      ];

  static List<AppNotification> notifications() => [
        AppNotification(
          id: 'n1',
          title: 'لقاء بعد 30 دقيقة',
          subtitle: 'أساسيات الهندسة الإبداعية',
          timeLabel: 'منذ دقيقتين',
          iconBody: IconBodies.calendar,
          iconColor: AppColors.primary,
          read: false,
        ),
        AppNotification(
          id: 'n2',
          title: 'واجب جديد',
          subtitle: 'تقرير مشروع العلوم',
          timeLabel: 'منذ ساعة',
          iconBody: IconBodies.pencil,
          iconColor: AppColors.warning,
          read: false,
        ),
        AppNotification(
          id: 'n3',
          title: 'شارة جديدة!',
          subtitle: 'نجم الرياضيات',
          timeLabel: 'أمس',
          iconBody: IconBodies.medal,
          iconColor: AppColors.primaryLight,
          read: false,
        ),
        AppNotification(
          id: 'n4',
          title: 'تم تصحيح واجبك',
          subtitle: 'اختبار الرياضيات — 92%',
          timeLabel: 'أمس',
          iconBody: IconBodies.checkCircle,
          iconColor: AppColors.sky,
          read: true,
        ),
        AppNotification(
          id: 'n5',
          title: 'رسالة من خدمة العملاء',
          subtitle: 'تم حل استفسارك بنجاح',
          timeLabel: 'قبل يومين',
          iconBody: IconBodies.chat,
          iconColor: AppColors.textMuted,
          read: true,
        ),
      ];

  static const skillScores = [
    SkillScore('التفكير النقدي', 88, AppColors.primary),
    SkillScore('الإبداع', 75, AppColors.primaryLight),
    SkillScore('حل المشكلات', 91, AppColors.sky),
    SkillScore('التواصل', 68, AppColors.coral),
  ];

  static const monthlyReports = [
    MonthlyReport('تقرير يوليو الشهري', 'صدر في 1 يوليو • 1.2 MB'),
    MonthlyReport('تقرير يونيو الشهري', 'صدر في 1 يونيو • 1.1 MB'),
  ];

  static const badges = [
    AchievementBadge('🥇', 'الحضور المثالي'),
    AchievementBadge('🧠', 'عبقري الرياضيات'),
    AchievementBadge('🎨', 'مبدع الفنون'),
    AchievementBadge('', 'مغلقة', locked: true),
    AchievementBadge('', 'مغلقة', locked: true),
    AchievementBadge('', 'مغلقة', locked: true),
  ];

  static const leaderboard = [
    LeaderboardEntry(1, 'لمى عبدالله', 2340, AppColors.primaryLight),
    LeaderboardEntry(2, 'سارة الغامدي', 2210, AppColors.sky),
    LeaderboardEntry(3, 'عبدالعزيز نور', 2095, AppColors.coral),
  ];

  static const weeklyActivity = [0.4, 0.6, 0.75, 0.5, 0.65, 0.85, 0.35];
  static const weekDayLabels = ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];

  static const supportSeed = [
    ChatMessage('مرحبًا! كيف يمكنني مساعدتك اليوم؟'),
    ChatMessage('لم يصلني رمز التحقق عبر البريد', fromUser: true),
    ChatMessage('تم إعادة إرسال الرمز، تحقق من صندوق الوارد 📩'),
  ];
}
