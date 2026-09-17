-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "UserStatus" AS ENUM ('ACTIVE', 'DISABLED');

-- CreateEnum
CREATE TYPE "StaffRole" AS ENUM ('ALIF_SUPER_ADMIN', 'PROGRAM_MANAGER', 'ALIF_TRAINER', 'SCHOOL_ADMIN', 'TALENT_SPECIALIST');

-- CreateEnum
CREATE TYPE "SchoolStatus" AS ENUM ('ACTIVE', 'SUSPENDED', 'ARCHIVED');

-- CreateEnum
CREATE TYPE "StudentStatus" AS ENUM ('ACTIVE', 'DISABLED', 'GRADUATED');

-- CreateEnum
CREATE TYPE "SubscriptionStatus" AS ENUM ('DRAFT', 'ACTIVE', 'SUSPENDED', 'EXPIRED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "BillingPeriod" AS ENUM ('MONTHLY', 'TERM');

-- CreateEnum
CREATE TYPE "InvoiceStatus" AS ENUM ('DRAFT', 'ISSUED', 'PARTIALLY_PAID', 'PAID', 'OVERDUE', 'CANCELLED');

-- CreateEnum
CREATE TYPE "LeadStatus" AS ENUM ('NEW', 'CONTACTED', 'QUALIFIED', 'PROPOSAL', 'WON', 'LOST');

-- CreateEnum
CREATE TYPE "LeadActivityType" AS ENUM ('CALL', 'EMAIL', 'MEETING', 'NOTE');

-- CreateEnum
CREATE TYPE "ProgramVersionStatus" AS ENUM ('DRAFT', 'PUBLISHED', 'RETIRED');

-- CreateEnum
CREATE TYPE "ProgramItemType" AS ENUM ('CONTENT', 'ACTIVITY', 'QUESTION', 'RESOURCE', 'BREAK');

-- CreateEnum
CREATE TYPE "SubmissionMode" AS ENUM ('NONE', 'TEXT', 'CHOICE', 'FILE', 'TRAINER_EVALUATION');

-- CreateEnum
CREATE TYPE "ExtensionScope" AS ENUM ('SCHOOL', 'PROGRAM_RUN');

-- CreateEnum
CREATE TYPE "ExtensionStatus" AS ENUM ('ACTIVE', 'NEEDS_PLACEMENT_REVIEW');

-- CreateEnum
CREATE TYPE "PlacementType" AS ENUM ('BEFORE_ITEM', 'AFTER_ITEM', 'END_OF_UNIT');

-- CreateEnum
CREATE TYPE "RunStatus" AS ENUM ('DRAFT', 'SCHEDULED', 'ACTIVE', 'COMPLETED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "EnrollmentStatus" AS ENUM ('ACTIVE', 'COMPLETED', 'WITHDRAWN');

-- CreateEnum
CREATE TYPE "SessionStatus" AS ENUM ('SCHEDULED', 'LIVE', 'COMPLETED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "AttendanceStatus" AS ENUM ('PRESENT', 'PARTIAL', 'ABSENT', 'EXCUSED', 'OVERRIDDEN');

-- CreateEnum
CREATE TYPE "RecordingStatus" AS ENUM ('PENDING', 'RECORDING', 'PROCESSING', 'AVAILABLE', 'EXPIRED', 'GRACE_PERIOD', 'DELETED', 'FAILED');

-- CreateEnum
CREATE TYPE "ReportStatus" AS ENUM ('PENDING', 'GENERATING', 'READY', 'SENT', 'FAILED');

-- CreateEnum
CREATE TYPE "NotificationChannel" AS ENUM ('EMAIL', 'PUSH', 'IN_APP');

-- CreateEnum
CREATE TYPE "NotificationStatus" AS ENUM ('QUEUED', 'SENT', 'FAILED', 'READ');

-- CreateEnum
CREATE TYPE "ContentStatus" AS ENUM ('DRAFT', 'PUBLISHED', 'ARCHIVED');

-- CreateTable
CREATE TABLE "User" (
    "id" UUID NOT NULL,
    "email" VARCHAR(320),
    "passwordHash" TEXT,
    "name" VARCHAR(200) NOT NULL,
    "status" "UserStatus" NOT NULL DEFAULT 'ACTIVE',
    "tokenVersion" INTEGER NOT NULL DEFAULT 0,
    "lastLoginAt" TIMESTAMPTZ(3),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RefreshSession" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "familyId" UUID NOT NULL,
    "expiresAt" TIMESTAMPTZ(3) NOT NULL,
    "revokedAt" TIMESTAMPTZ(3),
    "replacedById" UUID,
    "ipAddress" VARCHAR(64),
    "userAgent" VARCHAR(500),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "RefreshSession_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "School" (
    "id" UUID NOT NULL,
    "code" VARCHAR(20) NOT NULL,
    "name" VARCHAR(200) NOT NULL,
    "status" "SchoolStatus" NOT NULL DEFAULT 'ACTIVE',
    "settings" JSONB,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "School_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StaffMembership" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "schoolId" UUID,
    "role" "StaffRole" NOT NULL,
    "canTrain" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "StaffMembership_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SchoolClass" (
    "id" UUID NOT NULL,
    "schoolId" UUID NOT NULL,
    "name" VARCHAR(120) NOT NULL,
    "grade" VARCHAR(50) NOT NULL,
    "academicTerm" VARCHAR(100),
    "active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "SchoolClass_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Student" (
    "id" UUID NOT NULL,
    "schoolId" UUID NOT NULL,
    "name" VARCHAR(200) NOT NULL,
    "grade" VARCHAR(50) NOT NULL,
    "status" "StudentStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "Student_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StudentAccessCredential" (
    "id" UUID NOT NULL,
    "schoolId" UUID NOT NULL,
    "studentId" UUID NOT NULL,
    "codeHash" TEXT NOT NULL,
    "codeLookup" TEXT NOT NULL,
    "codeHint" VARCHAR(4) NOT NULL,
    "revokedAt" TIMESTAMPTZ(3),
    "generatedAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "StudentAccessCredential_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StudentSession" (
    "id" UUID NOT NULL,
    "schoolId" UUID NOT NULL,
    "studentId" UUID NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "expiresAt" TIMESTAMPTZ(3) NOT NULL,
    "revokedAt" TIMESTAMPTZ(3),
    "deviceId" VARCHAR(200),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "StudentSession_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Guardian" (
    "id" UUID NOT NULL,
    "schoolId" UUID NOT NULL,
    "name" VARCHAR(200) NOT NULL,
    "email" VARCHAR(320) NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Guardian_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StudentGuardian" (
    "id" UUID NOT NULL,
    "schoolId" UUID NOT NULL,
    "studentId" UUID NOT NULL,
    "guardianId" UUID NOT NULL,
    "relationship" VARCHAR(80) NOT NULL,
    "receiveSessionSummaries" BOOLEAN NOT NULL DEFAULT true,
    "receiveFinalReports" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "StudentGuardian_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ClassStudent" (
    "id" UUID NOT NULL,
    "schoolId" UUID NOT NULL,
    "classId" UUID NOT NULL,
    "studentId" UUID NOT NULL,

    CONSTRAINT "ClassStudent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Plan" (
    "id" UUID NOT NULL,
    "name" VARCHAR(120) NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "Plan_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Entitlement" (
    "id" UUID NOT NULL,
    "key" VARCHAR(100) NOT NULL,
    "description" VARCHAR(500),

    CONSTRAINT "Entitlement_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PlanEntitlement" (
    "planId" UUID NOT NULL,
    "entitlementId" UUID NOT NULL,
    "value" JSONB NOT NULL,

    CONSTRAINT "PlanEntitlement_pkey" PRIMARY KEY ("planId","entitlementId")
);

-- CreateTable
CREATE TABLE "Subscription" (
    "id" UUID NOT NULL,
    "schoolId" UUID NOT NULL,
    "planId" UUID NOT NULL,
    "status" "SubscriptionStatus" NOT NULL DEFAULT 'DRAFT',
    "period" "BillingPeriod" NOT NULL,
    "startsAt" TIMESTAMPTZ(3) NOT NULL,
    "endsAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "Subscription_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Invoice" (
    "id" UUID NOT NULL,
    "schoolId" UUID NOT NULL,
    "subscriptionId" UUID,
    "number" VARCHAR(50) NOT NULL,
    "status" "InvoiceStatus" NOT NULL DEFAULT 'DRAFT',
    "currency" CHAR(3) NOT NULL DEFAULT 'SAR',
    "total" DECIMAL(12,2) NOT NULL,
    "dueAt" TIMESTAMPTZ(3),
    "issuedAt" TIMESTAMPTZ(3),

    CONSTRAINT "Invoice_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Payment" (
    "id" UUID NOT NULL,
    "schoolId" UUID NOT NULL,
    "invoiceId" UUID NOT NULL,
    "amount" DECIMAL(12,2) NOT NULL,
    "paidAt" TIMESTAMPTZ(3) NOT NULL,
    "method" VARCHAR(80) NOT NULL,
    "reference" VARCHAR(200),
    "notes" TEXT,
    "attachmentKey" TEXT,

    CONSTRAINT "Payment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Lead" (
    "id" UUID NOT NULL,
    "schoolName" VARCHAR(200) NOT NULL,
    "contactName" VARCHAR(200) NOT NULL,
    "email" VARCHAR(320) NOT NULL,
    "phone" VARCHAR(50),
    "approximateStudents" INTEGER,
    "approximateClasses" INTEGER,
    "interestedPrograms" JSONB,
    "message" TEXT,
    "status" "LeadStatus" NOT NULL DEFAULT 'NEW',
    "convertedSchoolId" UUID,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Lead_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LeadActivity" (
    "id" UUID NOT NULL,
    "leadId" UUID NOT NULL,
    "type" "LeadActivityType" NOT NULL,
    "body" TEXT NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "LeadActivity_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Program" (
    "id" UUID NOT NULL,
    "title" VARCHAR(250) NOT NULL,
    "slug" VARCHAR(250) NOT NULL,
    "category" VARCHAR(120),
    "coverKey" TEXT,
    "targetGrades" JSONB,
    "targetAges" JSONB,
    "marketing" JSONB,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Program_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProgramVersion" (
    "id" UUID NOT NULL,
    "programId" UUID NOT NULL,
    "version" INTEGER NOT NULL,
    "status" "ProgramVersionStatus" NOT NULL DEFAULT 'DRAFT',
    "description" TEXT,
    "trainingDays" INTEGER,
    "trainingHours" DECIMAL(6,2),
    "learningOutcomes" JSONB,
    "assessmentRules" JSONB,
    "recordingPolicy" JSONB,
    "publishedAt" TIMESTAMPTZ(3),

    CONSTRAINT "ProgramVersion_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProgramSection" (
    "id" UUID NOT NULL,
    "programVersionId" UUID NOT NULL,
    "title" VARCHAR(250) NOT NULL,
    "position" INTEGER NOT NULL,

    CONSTRAINT "ProgramSection_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProgramUnit" (
    "id" UUID NOT NULL,
    "sectionId" UUID NOT NULL,
    "title" VARCHAR(250) NOT NULL,
    "position" INTEGER NOT NULL,

    CONSTRAINT "ProgramUnit_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProgramLesson" (
    "id" UUID NOT NULL,
    "unitId" UUID NOT NULL,
    "title" VARCHAR(250) NOT NULL,
    "position" INTEGER NOT NULL,

    CONSTRAINT "ProgramLesson_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProgramItem" (
    "id" UUID NOT NULL,
    "lessonId" UUID NOT NULL,
    "type" "ProgramItemType" NOT NULL,
    "title" VARCHAR(250) NOT NULL,
    "content" JSONB,
    "durationMinutes" INTEGER,
    "submissionMode" "SubmissionMode" NOT NULL DEFAULT 'NONE',
    "position" INTEGER NOT NULL,

    CONSTRAINT "ProgramItem_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Competency" (
    "id" UUID NOT NULL,
    "key" VARCHAR(100) NOT NULL,
    "name" VARCHAR(200) NOT NULL,
    "description" TEXT,

    CONSTRAINT "Competency_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProgramCompetency" (
    "programVersionId" UUID NOT NULL,
    "competencyId" UUID NOT NULL,

    CONSTRAINT "ProgramCompetency_pkey" PRIMARY KEY ("programVersionId","competencyId")
);

-- CreateTable
CREATE TABLE "ItemCompetency" (
    "programItemId" UUID NOT NULL,
    "competencyId" UUID NOT NULL,

    CONSTRAINT "ItemCompetency_pkey" PRIMARY KEY ("programItemId","competencyId")
);

-- CreateTable
CREATE TABLE "AssessmentScale" (
    "id" UUID NOT NULL,
    "programVersionId" UUID NOT NULL,
    "name" VARCHAR(150) NOT NULL,

    CONSTRAINT "AssessmentScale_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AssessmentScaleLevel" (
    "id" UUID NOT NULL,
    "scaleId" UUID NOT NULL,
    "value" INTEGER NOT NULL,
    "label" VARCHAR(120) NOT NULL,
    "position" INTEGER NOT NULL,

    CONSTRAINT "AssessmentScaleLevel_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProgramRun" (
    "id" UUID NOT NULL,
    "schoolId" UUID NOT NULL,
    "programVersionId" UUID NOT NULL,
    "name" VARCHAR(200) NOT NULL,
    "academicTerm" VARCHAR(100),
    "trainerMembershipId" UUID,
    "specialistMembershipId" UUID,
    "startsAt" TIMESTAMPTZ(3) NOT NULL,
    "endsAt" TIMESTAMPTZ(3) NOT NULL,
    "recordingRetentionDays" INTEGER NOT NULL DEFAULT 30,
    "status" "RunStatus" NOT NULL DEFAULT 'DRAFT',

    CONSTRAINT "ProgramRun_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProgramExtension" (
    "id" UUID NOT NULL,
    "schoolId" UUID NOT NULL,
    "programVersionId" UUID NOT NULL,
    "runId" UUID,
    "unitId" UUID,
    "anchorItemId" UUID,
    "scope" "ExtensionScope" NOT NULL,
    "status" "ExtensionStatus" NOT NULL DEFAULT 'ACTIVE',
    "placement" "PlacementType" NOT NULL,
    "itemType" "ProgramItemType" NOT NULL,
    "title" VARCHAR(250) NOT NULL,
    "content" JSONB,
    "createdById" UUID NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ProgramExtension_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Enrollment" (
    "id" UUID NOT NULL,
    "schoolId" UUID NOT NULL,
    "runId" UUID NOT NULL,
    "studentId" UUID NOT NULL,
    "status" "EnrollmentStatus" NOT NULL DEFAULT 'ACTIVE',
    "enrolledAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Enrollment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LearningSession" (
    "id" UUID NOT NULL,
    "schoolId" UUID NOT NULL,
    "runId" UUID NOT NULL,
    "title" VARCHAR(250) NOT NULL,
    "scheduledStart" TIMESTAMPTZ(3) NOT NULL,
    "scheduledEnd" TIMESTAMPTZ(3) NOT NULL,
    "startedAt" TIMESTAMPTZ(3),
    "endedAt" TIMESTAMPTZ(3),
    "status" "SessionStatus" NOT NULL DEFAULT 'SCHEDULED',
    "liveProviderRef" TEXT,

    CONSTRAINT "LearningSession_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Attendance" (
    "id" UUID NOT NULL,
    "schoolId" UUID NOT NULL,
    "sessionId" UUID NOT NULL,
    "studentId" UUID NOT NULL,
    "firstJoinedAt" TIMESTAMPTZ(3),
    "lastLeftAt" TIMESTAMPTZ(3),
    "connectedSeconds" INTEGER NOT NULL DEFAULT 0,
    "attendancePercentage" DECIMAL(5,2) NOT NULL DEFAULT 0,
    "status" "AttendanceStatus" NOT NULL DEFAULT 'ABSENT',
    "overrideReason" TEXT,
    "overriddenById" UUID,

    CONSTRAINT "Attendance_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AttendanceEvent" (
    "id" UUID NOT NULL,
    "schoolId" UUID NOT NULL,
    "sessionId" UUID NOT NULL,
    "studentId" UUID NOT NULL,
    "joinedAt" TIMESTAMPTZ(3) NOT NULL,
    "leftAt" TIMESTAMPTZ(3),

    CONSTRAINT "AttendanceEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ChatMessage" (
    "id" UUID NOT NULL,
    "schoolId" UUID NOT NULL,
    "sessionId" UUID,
    "studentId" UUID NOT NULL,
    "trainerUserId" UUID NOT NULL,
    "senderType" VARCHAR(20) NOT NULL,
    "body" TEXT NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ChatMessage_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StudentAssessment" (
    "id" UUID NOT NULL,
    "schoolId" UUID NOT NULL,
    "sessionId" UUID,
    "studentId" UUID NOT NULL,
    "programItemId" UUID,
    "competencyId" UUID,
    "scaleLevelId" UUID,
    "notes" TEXT,
    "assessedById" UUID NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "StudentAssessment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StudentObservation" (
    "id" UUID NOT NULL,
    "schoolId" UUID NOT NULL,
    "sessionId" UUID,
    "studentId" UUID NOT NULL,
    "authorUserId" UUID NOT NULL,
    "body" TEXT NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "StudentObservation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Recording" (
    "id" UUID NOT NULL,
    "schoolId" UUID NOT NULL,
    "sessionId" UUID NOT NULL,
    "status" "RecordingStatus" NOT NULL DEFAULT 'PENDING',
    "providerRef" TEXT,
    "objectKey" TEXT,
    "availableAt" TIMESTAMPTZ(3),
    "expiresAt" TIMESTAMPTZ(3),
    "deleteAfter" TIMESTAMPTZ(3),
    "durationSeconds" INTEGER,

    CONSTRAINT "Recording_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RecordingView" (
    "id" UUID NOT NULL,
    "schoolId" UUID NOT NULL,
    "recordingId" UUID NOT NULL,
    "studentId" UUID NOT NULL,
    "firstViewedAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastViewedAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "watchedSeconds" INTEGER NOT NULL DEFAULT 0,
    "completionPercent" DECIMAL(5,2) NOT NULL DEFAULT 0,

    CONSTRAINT "RecordingView_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StudentReport" (
    "id" UUID NOT NULL,
    "schoolId" UUID NOT NULL,
    "studentId" UUID NOT NULL,
    "runId" UUID NOT NULL,
    "status" "ReportStatus" NOT NULL DEFAULT 'PENDING',
    "snapshot" JSONB,
    "htmlKey" TEXT,
    "pdfKey" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "StudentReport_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MessageTemplate" (
    "id" UUID NOT NULL,
    "key" VARCHAR(100) NOT NULL,
    "channel" "NotificationChannel" NOT NULL,
    "subject" TEXT,
    "body" TEXT NOT NULL,
    "variables" JSONB,
    "active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "MessageTemplate_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Notification" (
    "id" UUID NOT NULL,
    "schoolId" UUID,
    "userId" UUID,
    "studentId" UUID,
    "channel" "NotificationChannel" NOT NULL,
    "type" VARCHAR(100) NOT NULL,
    "title" VARCHAR(250) NOT NULL,
    "body" TEXT NOT NULL,
    "payload" JSONB,
    "status" "NotificationStatus" NOT NULL DEFAULT 'QUEUED',
    "sentAt" TIMESTAMPTZ(3),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Notification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CmsPage" (
    "id" UUID NOT NULL,
    "slug" VARCHAR(250) NOT NULL,
    "title" VARCHAR(250) NOT NULL,
    "sections" JSONB NOT NULL,
    "seo" JSONB,
    "status" "ContentStatus" NOT NULL DEFAULT 'DRAFT',
    "publishedAt" TIMESTAMPTZ(3),

    CONSTRAINT "CmsPage_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BlogPost" (
    "id" UUID NOT NULL,
    "slug" VARCHAR(250) NOT NULL,
    "title" VARCHAR(250) NOT NULL,
    "excerpt" TEXT,
    "featuredImage" TEXT,
    "content" JSONB NOT NULL,
    "category" VARCHAR(120),
    "authorUserId" UUID NOT NULL,
    "seo" JSONB,
    "status" "ContentStatus" NOT NULL DEFAULT 'DRAFT',
    "publishedAt" TIMESTAMPTZ(3),

    CONSTRAINT "BlogPost_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AuditLog" (
    "id" UUID NOT NULL,
    "schoolId" UUID,
    "actorUserId" UUID,
    "action" VARCHAR(100) NOT NULL,
    "entityType" VARCHAR(100) NOT NULL,
    "entityId" VARCHAR(100),
    "before" JSONB,
    "after" JSONB,
    "metadata" JSONB,
    "ipAddress" VARCHAR(64),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE INDEX "User_status_idx" ON "User"("status");

-- CreateIndex
CREATE UNIQUE INDEX "RefreshSession_tokenHash_key" ON "RefreshSession"("tokenHash");

-- CreateIndex
CREATE INDEX "RefreshSession_userId_revokedAt_idx" ON "RefreshSession"("userId", "revokedAt");

-- CreateIndex
CREATE INDEX "RefreshSession_familyId_idx" ON "RefreshSession"("familyId");

-- CreateIndex
CREATE INDEX "RefreshSession_expiresAt_idx" ON "RefreshSession"("expiresAt");

-- CreateIndex
CREATE UNIQUE INDEX "School_code_key" ON "School"("code");

-- CreateIndex
CREATE INDEX "School_status_idx" ON "School"("status");

-- CreateIndex
CREATE INDEX "StaffMembership_schoolId_role_idx" ON "StaffMembership"("schoolId", "role");

-- CreateIndex
CREATE UNIQUE INDEX "StaffMembership_userId_schoolId_role_key" ON "StaffMembership"("userId", "schoolId", "role");

-- CreateIndex
CREATE INDEX "SchoolClass_schoolId_active_idx" ON "SchoolClass"("schoolId", "active");

-- CreateIndex
CREATE UNIQUE INDEX "SchoolClass_schoolId_name_academicTerm_key" ON "SchoolClass"("schoolId", "name", "academicTerm");

-- CreateIndex
CREATE INDEX "Student_schoolId_status_idx" ON "Student"("schoolId", "status");

-- CreateIndex
CREATE INDEX "Student_schoolId_name_idx" ON "Student"("schoolId", "name");

-- CreateIndex
CREATE UNIQUE INDEX "StudentAccessCredential_studentId_key" ON "StudentAccessCredential"("studentId");

-- CreateIndex
CREATE UNIQUE INDEX "StudentAccessCredential_codeLookup_key" ON "StudentAccessCredential"("codeLookup");

-- CreateIndex
CREATE INDEX "StudentAccessCredential_schoolId_revokedAt_idx" ON "StudentAccessCredential"("schoolId", "revokedAt");

-- CreateIndex
CREATE UNIQUE INDEX "StudentSession_tokenHash_key" ON "StudentSession"("tokenHash");

-- CreateIndex
CREATE INDEX "StudentSession_schoolId_studentId_revokedAt_idx" ON "StudentSession"("schoolId", "studentId", "revokedAt");

-- CreateIndex
CREATE INDEX "Guardian_schoolId_email_idx" ON "Guardian"("schoolId", "email");

-- CreateIndex
CREATE INDEX "StudentGuardian_schoolId_guardianId_idx" ON "StudentGuardian"("schoolId", "guardianId");

-- CreateIndex
CREATE UNIQUE INDEX "StudentGuardian_studentId_guardianId_key" ON "StudentGuardian"("studentId", "guardianId");

-- CreateIndex
CREATE INDEX "ClassStudent_schoolId_studentId_idx" ON "ClassStudent"("schoolId", "studentId");

-- CreateIndex
CREATE UNIQUE INDEX "ClassStudent_classId_studentId_key" ON "ClassStudent"("classId", "studentId");

-- CreateIndex
CREATE UNIQUE INDEX "Entitlement_key_key" ON "Entitlement"("key");

-- CreateIndex
CREATE INDEX "Subscription_schoolId_status_idx" ON "Subscription"("schoolId", "status");

-- CreateIndex
CREATE INDEX "Subscription_endsAt_idx" ON "Subscription"("endsAt");

-- CreateIndex
CREATE UNIQUE INDEX "Invoice_number_key" ON "Invoice"("number");

-- CreateIndex
CREATE INDEX "Invoice_schoolId_status_idx" ON "Invoice"("schoolId", "status");

-- CreateIndex
CREATE INDEX "Payment_schoolId_invoiceId_idx" ON "Payment"("schoolId", "invoiceId");

-- CreateIndex
CREATE INDEX "Lead_status_createdAt_idx" ON "Lead"("status", "createdAt");

-- CreateIndex
CREATE INDEX "LeadActivity_leadId_createdAt_idx" ON "LeadActivity"("leadId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "Program_slug_key" ON "Program"("slug");

-- CreateIndex
CREATE INDEX "ProgramVersion_status_idx" ON "ProgramVersion"("status");

-- CreateIndex
CREATE UNIQUE INDEX "ProgramVersion_programId_version_key" ON "ProgramVersion"("programId", "version");

-- CreateIndex
CREATE UNIQUE INDEX "ProgramSection_programVersionId_position_key" ON "ProgramSection"("programVersionId", "position");

-- CreateIndex
CREATE UNIQUE INDEX "ProgramUnit_sectionId_position_key" ON "ProgramUnit"("sectionId", "position");

-- CreateIndex
CREATE UNIQUE INDEX "ProgramLesson_unitId_position_key" ON "ProgramLesson"("unitId", "position");

-- CreateIndex
CREATE INDEX "ProgramItem_type_idx" ON "ProgramItem"("type");

-- CreateIndex
CREATE UNIQUE INDEX "ProgramItem_lessonId_position_key" ON "ProgramItem"("lessonId", "position");

-- CreateIndex
CREATE UNIQUE INDEX "Competency_key_key" ON "Competency"("key");

-- CreateIndex
CREATE UNIQUE INDEX "AssessmentScaleLevel_scaleId_value_key" ON "AssessmentScaleLevel"("scaleId", "value");

-- CreateIndex
CREATE UNIQUE INDEX "AssessmentScaleLevel_scaleId_position_key" ON "AssessmentScaleLevel"("scaleId", "position");

-- CreateIndex
CREATE INDEX "ProgramRun_schoolId_status_idx" ON "ProgramRun"("schoolId", "status");

-- CreateIndex
CREATE INDEX "ProgramRun_trainerMembershipId_startsAt_idx" ON "ProgramRun"("trainerMembershipId", "startsAt");

-- CreateIndex
CREATE INDEX "ProgramExtension_schoolId_programVersionId_scope_idx" ON "ProgramExtension"("schoolId", "programVersionId", "scope");

-- CreateIndex
CREATE INDEX "ProgramExtension_runId_idx" ON "ProgramExtension"("runId");

-- CreateIndex
CREATE INDEX "Enrollment_schoolId_studentId_status_idx" ON "Enrollment"("schoolId", "studentId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "Enrollment_runId_studentId_key" ON "Enrollment"("runId", "studentId");

-- CreateIndex
CREATE UNIQUE INDEX "LearningSession_liveProviderRef_key" ON "LearningSession"("liveProviderRef");

-- CreateIndex
CREATE INDEX "LearningSession_schoolId_scheduledStart_idx" ON "LearningSession"("schoolId", "scheduledStart");

-- CreateIndex
CREATE INDEX "LearningSession_runId_status_idx" ON "LearningSession"("runId", "status");

-- CreateIndex
CREATE INDEX "Attendance_schoolId_studentId_idx" ON "Attendance"("schoolId", "studentId");

-- CreateIndex
CREATE UNIQUE INDEX "Attendance_sessionId_studentId_key" ON "Attendance"("sessionId", "studentId");

-- CreateIndex
CREATE INDEX "AttendanceEvent_schoolId_sessionId_studentId_idx" ON "AttendanceEvent"("schoolId", "sessionId", "studentId");

-- CreateIndex
CREATE INDEX "ChatMessage_schoolId_studentId_createdAt_idx" ON "ChatMessage"("schoolId", "studentId", "createdAt");

-- CreateIndex
CREATE INDEX "StudentAssessment_schoolId_studentId_createdAt_idx" ON "StudentAssessment"("schoolId", "studentId", "createdAt");

-- CreateIndex
CREATE INDEX "StudentObservation_schoolId_studentId_createdAt_idx" ON "StudentObservation"("schoolId", "studentId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "Recording_providerRef_key" ON "Recording"("providerRef");

-- CreateIndex
CREATE INDEX "Recording_schoolId_status_expiresAt_idx" ON "Recording"("schoolId", "status", "expiresAt");

-- CreateIndex
CREATE INDEX "Recording_deleteAfter_idx" ON "Recording"("deleteAfter");

-- CreateIndex
CREATE INDEX "RecordingView_schoolId_studentId_idx" ON "RecordingView"("schoolId", "studentId");

-- CreateIndex
CREATE UNIQUE INDEX "RecordingView_recordingId_studentId_key" ON "RecordingView"("recordingId", "studentId");

-- CreateIndex
CREATE INDEX "StudentReport_schoolId_status_idx" ON "StudentReport"("schoolId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "StudentReport_runId_studentId_key" ON "StudentReport"("runId", "studentId");

-- CreateIndex
CREATE UNIQUE INDEX "MessageTemplate_key_channel_key" ON "MessageTemplate"("key", "channel");

-- CreateIndex
CREATE INDEX "Notification_userId_status_createdAt_idx" ON "Notification"("userId", "status", "createdAt");

-- CreateIndex
CREATE INDEX "Notification_schoolId_studentId_idx" ON "Notification"("schoolId", "studentId");

-- CreateIndex
CREATE UNIQUE INDEX "CmsPage_slug_key" ON "CmsPage"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "BlogPost_slug_key" ON "BlogPost"("slug");

-- CreateIndex
CREATE INDEX "BlogPost_status_publishedAt_idx" ON "BlogPost"("status", "publishedAt");

-- CreateIndex
CREATE INDEX "AuditLog_schoolId_createdAt_idx" ON "AuditLog"("schoolId", "createdAt");

-- CreateIndex
CREATE INDEX "AuditLog_actorUserId_createdAt_idx" ON "AuditLog"("actorUserId", "createdAt");

-- CreateIndex
CREATE INDEX "AuditLog_entityType_entityId_idx" ON "AuditLog"("entityType", "entityId");

-- AddForeignKey
ALTER TABLE "RefreshSession" ADD CONSTRAINT "RefreshSession_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StaffMembership" ADD CONSTRAINT "StaffMembership_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StaffMembership" ADD CONSTRAINT "StaffMembership_schoolId_fkey" FOREIGN KEY ("schoolId") REFERENCES "School"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SchoolClass" ADD CONSTRAINT "SchoolClass_schoolId_fkey" FOREIGN KEY ("schoolId") REFERENCES "School"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Student" ADD CONSTRAINT "Student_schoolId_fkey" FOREIGN KEY ("schoolId") REFERENCES "School"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StudentAccessCredential" ADD CONSTRAINT "StudentAccessCredential_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "Student"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StudentSession" ADD CONSTRAINT "StudentSession_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "Student"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Guardian" ADD CONSTRAINT "Guardian_schoolId_fkey" FOREIGN KEY ("schoolId") REFERENCES "School"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StudentGuardian" ADD CONSTRAINT "StudentGuardian_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "Student"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StudentGuardian" ADD CONSTRAINT "StudentGuardian_guardianId_fkey" FOREIGN KEY ("guardianId") REFERENCES "Guardian"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ClassStudent" ADD CONSTRAINT "ClassStudent_classId_fkey" FOREIGN KEY ("classId") REFERENCES "SchoolClass"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ClassStudent" ADD CONSTRAINT "ClassStudent_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "Student"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PlanEntitlement" ADD CONSTRAINT "PlanEntitlement_planId_fkey" FOREIGN KEY ("planId") REFERENCES "Plan"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PlanEntitlement" ADD CONSTRAINT "PlanEntitlement_entitlementId_fkey" FOREIGN KEY ("entitlementId") REFERENCES "Entitlement"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Subscription" ADD CONSTRAINT "Subscription_schoolId_fkey" FOREIGN KEY ("schoolId") REFERENCES "School"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Subscription" ADD CONSTRAINT "Subscription_planId_fkey" FOREIGN KEY ("planId") REFERENCES "Plan"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Invoice" ADD CONSTRAINT "Invoice_schoolId_fkey" FOREIGN KEY ("schoolId") REFERENCES "School"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Invoice" ADD CONSTRAINT "Invoice_subscriptionId_fkey" FOREIGN KEY ("subscriptionId") REFERENCES "Subscription"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES "Invoice"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LeadActivity" ADD CONSTRAINT "LeadActivity_leadId_fkey" FOREIGN KEY ("leadId") REFERENCES "Lead"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProgramVersion" ADD CONSTRAINT "ProgramVersion_programId_fkey" FOREIGN KEY ("programId") REFERENCES "Program"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProgramSection" ADD CONSTRAINT "ProgramSection_programVersionId_fkey" FOREIGN KEY ("programVersionId") REFERENCES "ProgramVersion"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProgramUnit" ADD CONSTRAINT "ProgramUnit_sectionId_fkey" FOREIGN KEY ("sectionId") REFERENCES "ProgramSection"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProgramLesson" ADD CONSTRAINT "ProgramLesson_unitId_fkey" FOREIGN KEY ("unitId") REFERENCES "ProgramUnit"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProgramItem" ADD CONSTRAINT "ProgramItem_lessonId_fkey" FOREIGN KEY ("lessonId") REFERENCES "ProgramLesson"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProgramCompetency" ADD CONSTRAINT "ProgramCompetency_programVersionId_fkey" FOREIGN KEY ("programVersionId") REFERENCES "ProgramVersion"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProgramCompetency" ADD CONSTRAINT "ProgramCompetency_competencyId_fkey" FOREIGN KEY ("competencyId") REFERENCES "Competency"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ItemCompetency" ADD CONSTRAINT "ItemCompetency_programItemId_fkey" FOREIGN KEY ("programItemId") REFERENCES "ProgramItem"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ItemCompetency" ADD CONSTRAINT "ItemCompetency_competencyId_fkey" FOREIGN KEY ("competencyId") REFERENCES "Competency"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AssessmentScale" ADD CONSTRAINT "AssessmentScale_programVersionId_fkey" FOREIGN KEY ("programVersionId") REFERENCES "ProgramVersion"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AssessmentScaleLevel" ADD CONSTRAINT "AssessmentScaleLevel_scaleId_fkey" FOREIGN KEY ("scaleId") REFERENCES "AssessmentScale"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProgramRun" ADD CONSTRAINT "ProgramRun_schoolId_fkey" FOREIGN KEY ("schoolId") REFERENCES "School"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProgramRun" ADD CONSTRAINT "ProgramRun_programVersionId_fkey" FOREIGN KEY ("programVersionId") REFERENCES "ProgramVersion"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProgramExtension" ADD CONSTRAINT "ProgramExtension_schoolId_fkey" FOREIGN KEY ("schoolId") REFERENCES "School"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProgramExtension" ADD CONSTRAINT "ProgramExtension_programVersionId_fkey" FOREIGN KEY ("programVersionId") REFERENCES "ProgramVersion"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProgramExtension" ADD CONSTRAINT "ProgramExtension_runId_fkey" FOREIGN KEY ("runId") REFERENCES "ProgramRun"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProgramExtension" ADD CONSTRAINT "ProgramExtension_unitId_fkey" FOREIGN KEY ("unitId") REFERENCES "ProgramUnit"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProgramExtension" ADD CONSTRAINT "ProgramExtension_anchorItemId_fkey" FOREIGN KEY ("anchorItemId") REFERENCES "ProgramItem"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProgramExtension" ADD CONSTRAINT "ProgramExtension_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Enrollment" ADD CONSTRAINT "Enrollment_runId_fkey" FOREIGN KEY ("runId") REFERENCES "ProgramRun"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Enrollment" ADD CONSTRAINT "Enrollment_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "Student"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LearningSession" ADD CONSTRAINT "LearningSession_runId_fkey" FOREIGN KEY ("runId") REFERENCES "ProgramRun"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Attendance" ADD CONSTRAINT "Attendance_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "LearningSession"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Attendance" ADD CONSTRAINT "Attendance_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "Student"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AttendanceEvent" ADD CONSTRAINT "AttendanceEvent_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "LearningSession"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ChatMessage" ADD CONSTRAINT "ChatMessage_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "LearningSession"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StudentAssessment" ADD CONSTRAINT "StudentAssessment_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "LearningSession"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StudentAssessment" ADD CONSTRAINT "StudentAssessment_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "Student"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StudentObservation" ADD CONSTRAINT "StudentObservation_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "LearningSession"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StudentObservation" ADD CONSTRAINT "StudentObservation_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "Student"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Recording" ADD CONSTRAINT "Recording_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "LearningSession"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RecordingView" ADD CONSTRAINT "RecordingView_recordingId_fkey" FOREIGN KEY ("recordingId") REFERENCES "Recording"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RecordingView" ADD CONSTRAINT "RecordingView_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "Student"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Notification" ADD CONSTRAINT "Notification_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_schoolId_fkey" FOREIGN KEY ("schoolId") REFERENCES "School"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_actorUserId_fkey" FOREIGN KEY ("actorUserId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- Domain invariants not expressible in Prisma's schema language.
ALTER TABLE "Subscription" ADD CONSTRAINT "Subscription_dates_check" CHECK ("startsAt" < "endsAt");
ALTER TABLE "Invoice" ADD CONSTRAINT "Invoice_total_check" CHECK ("total" >= 0);
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_amount_check" CHECK ("amount" > 0);
ALTER TABLE "ProgramVersion" ADD CONSTRAINT "ProgramVersion_duration_check" CHECK (("trainingDays" IS NULL OR "trainingDays" > 0) AND ("trainingHours" IS NULL OR "trainingHours" >= 0));
ALTER TABLE "ProgramRun" ADD CONSTRAINT "ProgramRun_dates_check" CHECK ("startsAt" < "endsAt");
ALTER TABLE "ProgramRun" ADD CONSTRAINT "ProgramRun_retention_check" CHECK ("recordingRetentionDays" > 0);
ALTER TABLE "LearningSession" ADD CONSTRAINT "LearningSession_dates_check" CHECK ("scheduledStart" < "scheduledEnd");
ALTER TABLE "Attendance" ADD CONSTRAINT "Attendance_duration_check" CHECK ("connectedSeconds" >= 0 AND "attendancePercentage" BETWEEN 0 AND 100);
ALTER TABLE "RecordingView" ADD CONSTRAINT "RecordingView_progress_check" CHECK ("watchedSeconds" >= 0 AND "completionPercent" BETWEEN 0 AND 100);
ALTER TABLE "StaffMembership" ADD CONSTRAINT "StaffMembership_scope_check" CHECK (
  ("role" IN ('ALIF_SUPER_ADMIN', 'PROGRAM_MANAGER', 'ALIF_TRAINER') AND "schoolId" IS NULL)
  OR ("role" IN ('SCHOOL_ADMIN', 'TALENT_SPECIALIST') AND "schoolId" IS NOT NULL)
);
ALTER TABLE "ProgramExtension" ADD CONSTRAINT "ProgramExtension_type_check" CHECK ("itemType" IN ('ACTIVITY', 'QUESTION', 'RESOURCE'));
ALTER TABLE "ProgramExtension" ADD CONSTRAINT "ProgramExtension_scope_check" CHECK (
  ("scope" = 'SCHOOL' AND "runId" IS NULL)
  OR ("scope" = 'PROGRAM_RUN' AND "runId" IS NOT NULL)
);
ALTER TABLE "ProgramExtension" ADD CONSTRAINT "ProgramExtension_anchor_check" CHECK (
  ("placement" = 'END_OF_UNIT' AND "unitId" IS NOT NULL)
  OR ("placement" IN ('BEFORE_ITEM', 'AFTER_ITEM') AND "anchorItemId" IS NOT NULL)
);

-- Audit entries are append-only.
CREATE OR REPLACE FUNCTION prevent_audit_mutation() RETURNS trigger AS $$
BEGIN
  RAISE EXCEPTION 'AuditLog records are immutable';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "AuditLog_no_update"
BEFORE UPDATE OR DELETE ON "AuditLog"
FOR EACH ROW EXECUTE FUNCTION prevent_audit_mutation();
