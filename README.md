# ألف المستقبل (Alef Future)

A Flutter mobile app for **منصة ألف** — a gifted-students education platform connecting
students and parents with live classes, assignments, achievements, and progress reports.
Fully RTL, in Arabic, built from a Claude Design handoff and running entirely on local
mock data (no backend).

## Features

- **Auth & onboarding** — splash, onboarding carousel, login (student/parent role toggle),
  password recovery (OTP), and a 2-step signup: school-issued join code → student/parent
  details, followed by a parent-consent form.
- **Home** — role-specific dashboard (student vs. parent), live meeting-of-the-day card,
  an always-on "live activity now" banner for trainer-pushed timed activities, stats,
  upcoming assignments, and past recordings.
- **Meetings** — list (list/calendar views, search & filters), a live in-meeting screen
  with participant tiles and an in-session poll, and a recording player with tabs for
  summary / related activities / FAQ.
- **Assignments** — list with status tabs, three work types (multiple-choice quiz, essay
  report, creative puzzle), a result/grade screen, and a congrats modal.
- **Live activity** — standalone timed-question screen opened from the home banner.
- **Achievements** — level, badges, progress toward the next badge, class leaderboard.
- **Reports** — performance charts, downloadable report list, and a report detail view.
- **Profile** — profile summary, settings (notifications, language, theme, password),
  notifications inbox, and a customer-support chat screen.
- Every list screen has loading / empty / error state variants, toggleable from
  Settings → "معاينة الحالات" for demoing.

## Tech stack

- **Flutter** (Dart), Material, [go_router](https://pub.dev/packages/go_router) for
  navigation (`lib/router/app_router.dart`)
- [provider](https://pub.dev/packages/provider) for app-wide state (`lib/state/app_state.dart`)
- [flutter_svg](https://pub.dev/packages/flutter_svg) for the icon set
- Tajawal font (bundled locally), full RTL layout via `Directionality`
- A responsive scaler in `lib/main.dart` that grows the whole UI on tablets rather than
  letterboxing it — see the doc comment on `_ResponsiveScaler` for the mechanics

## Project structure

```
lib/
  main.dart              # app entry, theme, responsive scaling
  router/                # go_router route table
  state/                 # AppState (role, demo-state toggles, mock data access)
  data/mock_data.dart     # all seed/demo data
  models/                # data models + enums
  theme/                  # colors, text styles, ThemeData
  widgets/                 # shared building blocks (buttons, cards, icons, nav bar...)
  screens/
    auth/                  # splash → onboarding → login/signup → consent
    home/                    # student/parent dashboards, live-activity screen
    meetings/                 # list, live meeting, recording
    assignments/               # list, quiz/essay/puzzle, result
    achievements/, reports/, profile/, support/
```

## Getting started

Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart ^3.12.2).

```bash
flutter pub get
flutter run                 # any connected device/simulator
flutter run -d chrome        # web
```

Build for release:

```bash
flutter build apk            # Android
flutter build ios            # iOS (macOS + Xcode required)
flutter build web            # Web
```

## Demo notes

The app has no backend — every screen is driven by mock data in `lib/data/mock_data.dart`
and `lib/state/app_state.dart`. A few things worth knowing when clicking through it:

- **Login** accepts any email/password; pick "طالب" or "ولي أمر" to see either dashboard.
- **Signup**'s school-code step validates the code `ALF6A2`; any other 6-character code
  shows the error state.
- Settings → "معاينة الحالات" toggles each list screen's loading/empty/error state for
  demoing without needing real data changes.

## Design source

Implemented from a Claude Design canvas export (`Alef Mobile App.dc.html`, 24 screens at
390×844) tracking the design's exact colors, type scale, and spacing — see the doc
comments in `lib/theme/app_colors.dart` and `lib/theme/app_text.dart`.
