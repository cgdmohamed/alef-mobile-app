# Alif Future API

NestJS modular-monolith API for the Alif Future Learning Platform.

## Implemented API slice

- Validated startup configuration, structured production logs, secure headers, CORS, request IDs, throttling, consistent errors, URI versioning, and OpenAPI.
- PostgreSQL/Prisma schema spanning identity, schools, students, guardians, commercial records, CRM, programs, runs, sessions, attendance, assessments, recordings, reporting, notifications, CMS, and audit.
- Staff email/password authentication with Argon2 and atomic rotating refresh sessions.
- Student school-code/access-code authentication with hashed, revocable child-friendly codes and device sessions.
- RBAC plus service-level school tenant checks.
- School and class management.
- Student/guardian creation, code regeneration, device logout on regeneration, disable/revocation, and scoped listing.
- Master programs, immutable published versions, nested generic curriculum, and public marketing output.
- Program runs, school-safe trainer assignment, student enrollment, and validated scheduling.
- Scoped school-role authorization that prevents cross-school privilege composition.
- Plans, entitlements, subscriptions, invoices, transactional payment reconciliation, CRM lead capture, activities, and won-lead conversion.
- Persistence primitives for media, imports, durable jobs, activity submissions, breakout rooms, provider webhooks, notification delivery, push devices, report delivery, and CMS navigation.

## Environment

Copy `.env.example` to `.env`. All values are validated before startup. Production secrets must be generated independently and must not use example values.

## Database

The initial migration includes database checks for date ranges, financial values, attendance percentages, role scope, school-extension restrictions, and append-only audit records.

```bash
pnpm prisma:generate
pnpm prisma:validate
pnpm prisma:migrate
pnpm prisma:seed
```

The seed is idempotent and creates only the initial Alif super administrator from environment variables.
