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
          id: 'm5',
          title: 'تحدي الرياضيات الأسبوعي',
          teacher: 'أ. سلطان العتيبي',
          timeLabel: 'الأربعاء 5:30 م',
          group: 'هذا الأسبوع',
          status: MeetingStatus.upcoming,
        ),
        const Meeting(
          id: 'm6',
          title: 'نقاش نادي العلوم',
          teacher: 'أ. نورة القحطاني',
          timeLabel: 'الثلاثاء 4:30 م',
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
        const Meeting(
          id: 'm7',
          title: 'أساسيات البرمجة بلغة سكراتش',
          teacher: 'أ. نورة القحطاني',
          timeLabel: 'الإثنين',
          group: 'منتهية',
          status: MeetingStatus.ended,
          recordingLength: '45:20',
        ),
        const Meeting(
          id: 'm8',
          title: 'مقدمة في التفكير التصميمي',
          teacher: 'أ. منيرة السالم',
          timeLabel: 'الأحد',
          group: 'منتهية',
          status: MeetingStatus.ended,
          recordingLength: '29:40',
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
          dueLabel: 'يسلّم غدًا',
        ),
        Assignment(
          id: 'a2',
          title: 'تقرير مشروع العلوم',
          kind: AssignmentKind.essay,
          meta: 'مقالي • 300 كلمة • 3 أيام متبقية',
          status: AssignmentStatus.inProgress,
          ctaLabel: 'ابدأ',
          dueLabel: '3 أيام متبقية',
        ),
        Assignment(
          id: 'a4',
          title: 'ورشة الروبوتات — تصميم ذراع آلية',
          kind: AssignmentKind.essay,
          meta: 'مشروع عملي • تسليم فيديو • أسبوع متبقٍ',
          status: AssignmentStatus.inProgress,
          ctaLabel: 'ابدأ',
          dueLabel: 'يسلّم بعد أسبوع',
        ),
        Assignment(
          id: 'a3',
          title: 'لغز الأشكال المنطقية',
          kind: AssignmentKind.puzzle,
          meta: 'لغز إبداعي • انتهى أمس',
          status: AssignmentStatus.late,
          ctaLabel: 'سلّم متأخرًا',
          dueLabel: 'انتهى أمس',
        ),
        Assignment(
          id: 'a5',
          title: 'اختبار العلوم — الوحدة 2',
          kind: AssignmentKind.quiz,
          meta: '12 سؤال • 92% • سُلّم قبل يومين',
          status: AssignmentStatus.submitted,
          ctaLabel: 'عرض النتيجة',
          dueLabel: 'سُلّم قبل يومين',
        ),
        Assignment(
          id: 'a6',
          title: 'مقال القراءة النقدية',
          kind: AssignmentKind.essay,
          meta: 'مقالي • 88% • سُلّم الأسبوع الماضي',
          status: AssignmentStatus.submitted,
          ctaLabel: 'عرض النتيجة',
          dueLabel: 'سُلّم الأسبوع الماضي',
        ),
        Assignment(
          id: 'a7',
          title: 'لغز الأنماط العددية',
          kind: AssignmentKind.puzzle,
          meta: 'لغز إبداعي • 100% • سُلّم قبل 3 أيام',
          status: AssignmentStatus.submitted,
          ctaLabel: 'عرض النتيجة',
          dueLabel: 'سُلّم قبل 3 أيام',
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
        AppNotification(
          id: 'n6',
          title: 'تذكير: اجتماع أولياء الأمور غدًا',
          subtitle: 'اجتماع افتراضي الساعة 5:00 م',
          timeLabel: 'منذ 3 ساعات',
          iconBody: IconBodies.calendar,
          iconColor: AppColors.sky,
          read: true,
        ),
        AppNotification(
          id: 'n7',
          title: 'إنجاز جديد: أسبوع حضور مثالي',
          subtitle: 'حافظت على حضور 100% لمدة أسبوع كامل',
          timeLabel: 'منذ 3 أيام',
          iconBody: IconBodies.medal,
          iconColor: AppColors.warning,
          read: true,
        ),
        AppNotification(
          id: 'n8',
          title: 'تم تعديل موعد اللقاء',
          subtitle: 'نادي القراءة الأسبوعي انتقل إلى الخميس',
          timeLabel: 'منذ 4 أيام',
          iconBody: IconBodies.calendar,
          iconColor: AppColors.primary,
          read: true,
        ),
        AppNotification(
          id: 'n9',
          title: 'رسالة جديدة من أ. منيرة السالم',
          subtitle: 'تحققي من ملاحظات اللقاء الأخير',
          timeLabel: 'منذ 5 أيام',
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
    MonthlyReport('تقرير مايو الشهري', 'صدر في 1 مايو • 1.0 MB'),
    MonthlyReport('تقرير أبريل الشهري', 'صدر في 1 أبريل • 0.9 MB'),
  ];

  static const badges = [
    AchievementBadge('🥇', 'الحضور المثالي'),
    AchievementBadge('🧠', 'عبقري الرياضيات'),
    AchievementBadge('🎨', 'مبدع الفنون'),
    AchievementBadge('📚', 'عاشق القراءة'),
    AchievementBadge('🤖', 'مبتكر الروبوتات'),
    AchievementBadge('⚡', 'سريع الإنجاز'),
    AchievementBadge('', 'مغلقة', locked: true),
    AchievementBadge('', 'مغلقة', locked: true),
    AchievementBadge('', 'مغلقة', locked: true),
  ];

  static const leaderboard = [
    LeaderboardEntry(1, 'لمى عبدالله', 2340, AppColors.primaryLight),
    LeaderboardEntry(2, 'سارة الغامدي', 2210, AppColors.sky),
    LeaderboardEntry(3, 'عبدالعزيز نور', 2095, AppColors.coral),
    LeaderboardEntry(4, 'ريان الحربي', 1980, AppColors.primary),
    LeaderboardEntry(5, 'جود العتيبي', 1875, AppColors.textDisabled),
  ];

  static const weeklyActivity = [0.4, 0.6, 0.75, 0.5, 0.65, 0.85, 0.35];
  static const weekDayLabels = ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];

  static const supportSeed = [
    ChatMessage('مرحبًا! كيف يمكنني مساعدتك اليوم؟'),
    ChatMessage('لم يصلني رمز التحقق عبر البريد', fromUser: true),
    ChatMessage('تم إعادة إرسال الرمز، تحقق من صندوق الوارد 📩'),
  ];
}
