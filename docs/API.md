# Alef Future — Mobile App API Reference

The endpoints the Flutter app (`app/lib/services/*_api.dart`) actually calls
against the backend at `D:\2026\Alif Future\v2\api`. Every endpoint below is
verified against the live NestJS controllers/DTOs, not just the Dart client —
if the two ever disagree, the backend is the source of truth and this file is
stale.

Full interactive Swagger docs for the *entire* API (including admin/school/
teacher-only routes) are served at `{API_BASE_URL}/docs` — this file is the
mobile-relevant subset, organized the way the app actually consumes it.

## Conventions

**Base URL** — `API_BASE_URL` compile-time define, default
`https://api.aliffuture.com`. Android emulators reach a local host API through
`http://10.0.2.2:3000`.

**Auth header** — `Authorization: Bearer <accessToken>` on every request
except `/auth/otp/request`, `/auth/otp/verify`, `/auth/signup`,
`/auth/refresh`, `/auth/logout` (all public).

**Roles relevant to mobile** — `student`, `parent`. Every endpoint below
lists which of the two (if either) it's restricted to.

**Error shape** — non-2xx responses return:

```json
{ "statusCode": 400, "message": "Incorrect verification code", "timestamp": "2026-09-03T12:00:00.000Z" }
```

`message` may be a string or an array of validation-error strings (from
`class-validator`) — the app's `ApiClient._errorMessage` joins arrays with
`, `.

**401 handling** — the app's `ApiClient` transparently attempts one
`/auth/refresh` call on any `401` and retries the original request once. If
the refresh itself fails, tokens are cleared and the app routes back to
`/login`.

**Rate limits** — global default is 100 req/min per client; auth endpoints
have tighter per-route limits (see [Auth](#auth--session)). Exceeding a limit
returns `429`.

**"404 means null" pattern** — several endpoints represent "this doesn't
exist yet, not an error" as a 404 that the corresponding Dart method catches
and turns into `null` rather than throwing. Called out per-endpoint below.

---

## Auth & Session

Mobile uses **email + OTP** exclusively — there is no password login on this
client (that's the web admin panel's flow, `POST /auth/login`, not used by
the app). The code is emailed (`EmailOtpSender`, API-side), not texted.

### `POST /auth/otp/request`
Public · limit **5/min**

| Body | Type |
|---|---|
| `email` | string |

→ `{ "sent": true, "expiresInSeconds": 300 }`

### `POST /auth/otp/verify`
Public · limit **10/min**

| Body | Type |
|---|---|
| `email` | string |
| `code` | string, 4–8 chars |

→ `{ "accessToken": "...", "refreshToken": "...", "user": { ...AuthUser } }`

Locks after **5** wrong attempts on the same code (`400 Too many incorrect
attempts — request a new code`) — request a fresh code via `otp/request`.

`AuthUser` shape (used across every auth response):
```ts
{ id, name, email: string | null, phone: string | null, role, schoolId: string | null, status }
```
`role` is `"student"` or `"parent"`. `status` is `"active"`,
`"pending_consent"` (student awaiting parent approval), or `"disabled"`.

### `POST /auth/signup`
Public · limit **5/min**

| Body | Type |
|---|---|
| `name` | string |
| `email` | string — becomes the OTP login identifier |
| `phone` | string, E.164, optional — contact metadata only |
| `role` | `"student"` \| `"parent"` |
| `enrollmentCode` | school code; required for a mobile student signup |
| `stage` | student stage |
| `parentName` | required for a mobile student signup |
| `parentEmail` | required for a mobile student signup |
| `parentPhone` | parent phone in E.164 format, optional |

→ `AuthUser`. Student signup validates and consumes the school code in the
same transaction, creates/links the roster row, and creates the active parent
account if it does not already exist. The student starts as
`status: "pending_consent"` and is kept on the waiting screen until approval.
No tokens are returned by signup.

### `POST /auth/parent-consent`
Roles: **parent** · limit **10/min**

| Body | Type |
|---|---|
| `studentId` | string — the student's **User id**, not a roster id |

→ `AuthUser` (the now-activated student). Also links the parent to the
student's school-roster row (`Student.parentUserId`) if one exists, which is
what powers `/home/parent` and `/reports/students/:id` for that parent.

### `POST /auth/refresh`
Public · limit **15/min**

| Body | Type |
|---|---|
| `refreshToken` | string |

→ `{ accessToken, refreshToken, user }` — rotates the refresh token (the old
one is revoked). Called automatically by `ApiClient` on a `401`, not
something screens call directly.

### `POST /auth/logout`
Public · limit **15/min**

| Body | Type |
|---|---|
| `refreshToken` | string |

→ `{ "loggedOut": true }`. Best-effort — the app clears local tokens
regardless of the response.

### `GET /auth/me`
Any authenticated user

→ `AuthUser` for the current session. Used on app start to restore/validate a
persisted session (`AppState.bootstrap`).

---

## Home (aggregate)

Purpose-built endpoints that bundle several domains into one call for each
role's dashboard.

### `GET /home/student`
Roles: **student**

→
```ts
{
  student: { id, userId, name, points },
  nextMeeting: Meeting | null,   // full Meeting entity, see Meetings below
  pendingAssignments: Assignment[],
  unreadNotifications: number
}
```

**404** if this account's `User` isn't linked to a school-roster `Student`
row yet (`ApiException` → `HomeApi.studentHome()` returns `null`). This
happens for a self-signup student who hasn't been matched into a class
roster by their school yet.

### `GET /home/parent`
Roles: **parent**

→
```ts
{
  children: { id, userId, name, stage, average, points, consentPending }[],
  unreadNotifications: number
}
```

`children` includes approved children and pending students whose registered
parent email matches the signed-in parent. Pending entries provide the student
User id required by `parent-consent`.

---

## Meetings

### `GET /meetings?scope=today|week|month`
Any authenticated user. Omit `scope` for all meetings.

→ array of:
```ts
{
  id, title, scheduledAt, durationMinutes,
  status: "scheduled" | "live" | "ended",
  agoraChannelName: string | null,
  classId,
  classEntity: { id, name, teacher: { name } | null, ... }
}
```

### `POST /meetings/:id/join`
Any authenticated user

→
```ts
{ "channelName": "alef-<meetingId>", "token": "<rtc token>", "appId": "<agora app id>", "uid": 0 }
```

This is an **Agora RTC** join credential, not a URL — pass it straight into
`agora_rtc_engine`'s `engine.joinChannel(token:, channelId: channelName,
uid:, options:)` along with the app's own `appId` (passed to
`engine.initialize(RtcEngineContext(appId: ...))`). **A fresh call is
required per join attempt** — the token is short-lived (2h) and
single-purpose, it is never cached or reused across sessions. `uid` is
always `0` (wildcard) — the token authorizes any numeric uid and each
client lets the Agora SDK assign its own uid on join. There's no
host/participant distinction — everyone gets full publish rights (Agora's
role concept only meaningfully restricts publishing in the "live
broadcasting" channel profile; this app uses "communication").

### `GET /meetings/:id/recording`
Any authenticated user

→ `{ title, playbackUrl, durationSeconds, views }`

**404** if no recording is available yet — `MeetingsApi.recording()` returns
`null`. Real (non-mock) cloud recordings additionally require Agora's
separate Cloud Recording REST API that isn't wired up yet, so this stays
`null` in production until that's built.

---

## Assignments

### `GET /students/me/assignments`
Roles: **student**

→ array of:
```ts
{
  id, title, kind: "quiz" | "essay" | "puzzle", dueAt,
  submission: { status: "in_progress" | "submitted" | "late" | "graded", grade: number | null } | null
}
```
`submission` is `null` if the student hasn't started it.

### `GET /assignments/:id`
Roles: **student, teacher** (student can only fetch their own class's
assignment)

→ full assignment detail including the class it belongs to.

### `POST /assignments/:id/submit`
Roles: **student**

| Body | Type |
|---|---|
| `answerPayload` | arbitrary JSON object |

The backend stores this as an opaque blob. The app loads assignment
instructions from the linked content block and sends the student's written
response. A human teacher grades submissions later via the admin panel.

→ `204`-style empty success (no meaningful body).

### `GET /assignments/:id/result`
Roles: **student**

→ `{ status, grade: number | null, teacherNote: string | null }`

**404** until a teacher has graded the submission —
`AssignmentsApi.result()` returns `null` in that case, which the app renders
as "لم يتم تصحيح الواجب بعد" (not graded yet) rather than fabricating a score.

---

## Achievements

### `GET /students/me/achievements`
Roles: **student**

→ array of `{ emoji, label, locked: boolean }`.

### `GET /classes/:classId/leaderboard`
Roles: **student, teacher**

→ class points leaderboard. **Not currently called by the app** — the mobile
achievements screen only shows badges; leaderboard integration was descoped
since the screen doesn't have a `classId` readily available for the current
student.

---

## Reports

### `GET /students/me/report`
Roles: **student** (not parent — see below)

→
```ts
{
  student: { id, name, ... },
  summary: { average: number, attendancePercent: number, points: number },
  submissions: { title, grade: number | null, ... }[],
  attendance: { title, status, ... }[]
}
```

**404** if this account has no linked roster `Student` row —
`ReportsApi.myReport()` returns `null`.

### `GET /reports/students/:id`
Roles: **school_admin, teacher, parent, student**

Same response shape as `/students/me/report`, for a specific roster
`Student.id`. **Ownership-enforced**: a `parent` may only fetch a child
they've completed consent for (`Student.parentUserId` match), a `student`
may only fetch their own row — otherwise `403`. This is what
`ReportsApi.childReport(studentId)` calls from `parent_home_screen.dart`.

> **Known gap**: there is no per-child variant of `/students/me/report` — a
> parent must use this endpoint with the specific child's roster id, not the
> `/students/me/report` endpoint (which is student-only).

---

## Notifications

### `GET /notifications`
Any authenticated user

→ array of `{ id, title, subtitle, createdAt, read: boolean }`.

### `PATCH /notifications/:id/read`
Any authenticated user — no body.

### `POST /notifications/read-all`
Any authenticated user — no body.

### `GET /notifications/unread-count`
Any authenticated user

→ `{ "count": number }`.

---

## Support Chat

Real-time-ish 1:1 chat with a human support agent — no bot/auto-reply on the
backend, so don't fabricate a "typing…" indicator or canned responses in the
UI (the app intentionally doesn't).

### `GET /support/conversations/mine`
Any authenticated user

→ `{ id, ... }` — finds the caller's open conversation or creates one.
Idempotent per user (returns the same open conversation on repeat calls).

### `GET /support/conversations/:id/messages`
Any authenticated user; the API enforces participant/staff ownership.

→ array of `{ id, sender: { id }, text, createdAt }`.

### `POST /support/conversations/:id/messages`
Any authenticated user

| Body | Type |
|---|---|
| `text` | string |

→ the created message, same shape as above.

---

## Enrollment

### `POST /enrollment/redeem`
Roles: **student**

| Body | Type |
|---|---|
| `code` | string — a code a school admin generated, format `ALEF-XXXX-XXXX` |

→ `{ classId, redeemed: true }`. Also links (or creates) the caller's
school-roster `Student` row and sets their `User.schoolId` — the mechanism
that turns a self-signup student into a fully functional roster-linked
account (unlocking `/home/student`, real assignments, and reports).

This endpoint remains available for existing authenticated students. New
mobile signups send `enrollmentCode` to `/auth/signup`, where validation,
account creation, roster linking, and code consumption happen atomically.

---

## Endpoints intentionally *not* used by mobile

- `POST /auth/login` (email+password) — web admin only.
- Everything under `/schools`, `/packages`, `/resources`, `/programs`,
  `/classes` (write side), `/teachers`, `/content-items`,
  `/auto-message-templates`, `/settings`, `/activity-log` — admin/school-admin
  only, no mobile UI surfaces them.
