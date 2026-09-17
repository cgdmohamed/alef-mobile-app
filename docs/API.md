# API Documentation

The previous mobile-specific OTP/parent API documented here was superseded by the approved Alif Future V1 contract.

The authoritative API contract is generated from the NestJS application:

- Swagger UI: `/docs`
- Versioned REST API: `/v1`
- OpenAPI source: controller and DTO metadata under `apps/api/src`

Current authentication models:

- Staff: `POST /v1/auth/staff/login` using email and password.
- Students: `POST /v1/auth/student/login` using school code and student access code.
- Guardians are contact records and do not authenticate.

See `apps/api/README.md` for setup, environment, migration, and validation commands.
