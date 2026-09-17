# Alif Future Learning Platform

Production-oriented implementation of the Alif Future multi-tenant Arabic learning platform.

## Repository status

Backend development is now the active milestone. The repository contains:

- `apps/api`: NestJS REST API, Prisma, PostgreSQL, Redis/BullMQ, OpenAPI, authentication, tenant authorization, and core domain APIs.
- Root Flutter project: the earlier mobile client. It is preserved temporarily and will be moved to `apps/mobile` and aligned with the API after backend completion.

The legacy Flutter authentication and parent flows are not the authoritative product contract. New backend endpoints follow the approved V1 specification.

## Backend setup

Requirements:

- Node.js 22+
- pnpm 9+
- PostgreSQL 17+
- Redis 7+
- Docker is optional for local dependencies

```bash
pnpm install
cp apps/api/.env.example apps/api/.env
docker compose -f docker-compose.dev.yml up -d
pnpm db:generate
pnpm db:migrate
pnpm --filter @alif/api prisma:seed
pnpm --filter @alif/api dev
```

API documentation is available at `http://localhost:3000/docs`. Liveness and dependency readiness are exposed at `/v1/health` and `/v1/ready`.

## Validation

```bash
pnpm db:validate
pnpm lint
pnpm typecheck
pnpm test
pnpm build
```

Flutter checks remain available with `flutter analyze` and `flutter test`.

## Security model

- Staff authenticate with email/password and rotating refresh sessions.
- Students authenticate separately with school code and child-friendly student access code.
- Guardians are contact records, never platform users.
- School-owned records carry `schoolId`; API services enforce tenant ownership independently of route IDs.
- Audit records are append-only at the database level.
- Initial Alif administrator credentials are supplied only through environment variables.
