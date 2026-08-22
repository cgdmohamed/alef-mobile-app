import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/school_code_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/parent_consent_screen.dart';
import '../screens/main_shell.dart';
import '../screens/home/home_router_screen.dart';
import '../screens/home/live_activity_screen.dart';
import '../screens/meetings/meetings_list_screen.dart';
import '../screens/meetings/live_meeting_screen.dart';
import '../screens/meetings/recording_screen.dart';
import '../screens/assignments/assignments_list_screen.dart';
import '../screens/assignments/assignment_work_screen.dart';
import '../screens/assignments/assignment_result_screen.dart';
import '../screens/achievements/achievements_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/reports/report_detail_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/profile/notifications_screen.dart';
import '../screens/support/support_screen.dart';
import '../state/app_state.dart';

GoRouter buildAppRouter(AppState appState) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SchoolCodeScreen()),
      GoRoute(path: '/signup/details', builder: (context, state) => const SignupScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const OtpScreen()),
      GoRoute(path: '/live-activity', builder: (context, state) => const LiveActivityScreen()),
      GoRoute(path: '/parent-consent', builder: (context, state) => const ParentConsentScreen()),
      GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(path: '/achievements', builder: (context, state) => const AchievementsScreen()),
      GoRoute(path: '/support', builder: (context, state) => const SupportScreen()),
      GoRoute(
        path: '/report/:id',
        builder: (context, state) => ReportDetailScreen(reportId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/meeting/live/:id',
        builder: (context, state) => LiveMeetingScreen(meetingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/meeting/recording/:id',
        builder: (context, state) => RecordingScreen(meetingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/assignment/:id',
        builder: (context, state) => AssignmentWorkScreen(assignmentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/assignment/:id/result',
        builder: (context, state) => AssignmentResultScreen(assignmentId: state.pathParameters['id']!),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/home', builder: (context, state) => const HomeRouterScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/assignments', builder: (context, state) => const AssignmentsListScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/meetings', builder: (context, state) => const MeetingsListScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/reports', builder: (context, state) => const ReportsScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen())],
          ),
        ],
      ),
    ],
  );
}
