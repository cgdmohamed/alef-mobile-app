# ألف المستقبل (Alef Future)

A Flutter mobile app for **منصة ألف** — a gifted-students education platform connecting
students and parents with live classes, assignments, achievements, and progress reports.
Fully RTL, in Arabic, originally built from a Claude Design canvas handoff and now wired
to the real Alef Future backend (`D:\2026\Alif Future\v2\api`, NestJS + Postgres) — see
`docs/API.md` for the full endpoint reference this app actually calls.

## Features

- **Auth & onboarding** — splash, onboarding carousel, email + OTP login (no
  password on this client — that's the web admin panel's flow), and a 2-step
  signup: school-issued join code → student/parent details. The API validates and
  consumes the code atomically, links the student to the class, and creates the parent
  account when needed. Students wait for parent approval before entering the app.
- **Home** — role-specific dashboard (student vs. parent), meeting-of-the-day card,
  stats, upcoming assignments, and past recordings.
- **Meetings** — list (list/calendar views, search & filters), a live in-meeting screen
  with a real Agora RTC video call (camera/mic, local + remote tiles), and real playback
  for available recordings.
- **Assignments** — list with status tabs, instructions loaded from the linked program
  content block, a written response flow, real submission, and teacher grading results.
- **Live activity** — standalone timed-question screen opened from the home banner.
- **Achievements** — level, badges, progress toward the next badge, class leaderboard.
- **Reports** — performance charts, downloadable report list, and a report detail view.
- **Profile** — profile summary, settings (notifications, language, theme, password),
  notifications inbox, and a customer-support chat screen (real 1:1 chat with a human
  agent — no bot/auto-reply).
- Every list screen has loading / empty / error state variants, toggleable from
  Settings → "معاينة الحالات" for demoing without needing a real failing backend.

## Tech stack

- **Flutter** (Dart), Material, [go_router](https://pub.dev/packages/go_router) for
  navigation (`lib/router/app_router.dart`)
- [provider](https://pub.dev/packages/provider) for app-wide state (`lib/state/app_state.dart`)
- [agora_rtc_engine](https://pub.dev/packages/agora_rtc_engine) for real live-meeting video
- [flutter_svg](https://pub.dev/packages/flutter_svg) for the icon set
- Tajawal font (bundled locally), full RTL layout via `Directionality`
- A responsive scaler in `lib/main.dart` that grows the whole UI on tablets rather than
  letterboxing it — see the doc comment on `_ResponsiveScaler` for the mechanics

## Project structure

```
lib/
  main.dart              # app entry, theme, responsive scaling
  router/                # go_router route table
  state/                 # AppState — auth session + demo view-state toggles
  services/               # API clients (auth, meetings, assignments, enrollment, ...)
  models/                # data models + enums
  theme/                  # colors, text styles, ThemeData
  widgets/                 # shared building blocks (buttons, cards, icons, nav bar...)
  screens/
    auth/                  # splash → onboarding → login/signup → consent
    home/                    # student/parent dashboards
    meetings/                 # list, live meeting (real Agora video), recording
    assignments/               # list, quiz/essay/puzzle, result
    achievements/, reports/, profile/, support/
docs/
  API.md                  # the backend endpoints this app actually calls
```

## Getting started

Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart ^3.12.2)
and the Alef Future API running (see `D:\2026\Alif Future\v2\api`'s own README —
`docker compose -f docker-compose.dev.yml up -d` for Postgres, then `npm run start:dev`).

```bash
flutter pub get
flutter run                 # defaults to https://api.aliffuture.com
flutter run -d chrome        # web
```

Point at a different backend with `--dart-define=API_BASE_URL=...`. Android emulators
reach a local host API through `http://10.0.2.2:3000`.

Build for release:

```bash
flutter build apk            # Android
flutter build ios            # iOS (macOS + Xcode required)
flutter build web            # Web
```

## Demo notes

- **Login** is email + OTP against the real backend — request a code, then verify it. In
  local dev (no `SMTP_HOST` configured on the backend), the code is logged to the
  backend's own terminal instead of actually being emailed.
- **Signup** validates the `ALEF-XXXX-XXXX` school code when the details form is submitted.
- Settings → "معاينة الحالات" toggles each list screen's loading/empty/error state for
  demoing without needing a real failing backend.

## Design source

Implemented from a Claude Design canvas export (`Alef Mobile App.dc.html`, 24 screens at
390×844) tracking the design's exact colors, type scale, and spacing — see the doc
comments in `lib/theme/app_colors.dart` and `lib/theme/app_text.dart`.
