CREATE TYPE "FileStatus" AS ENUM ('PENDING', 'AVAILABLE', 'QUARANTINED', 'DELETED');
CREATE TYPE "JobStatus" AS ENUM ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'CANCELLED');
CREATE TYPE "SubmissionStatus" AS ENUM ('DRAFT', 'SUBMITTED', 'GRADED', 'RETURNED');
CREATE TYPE "BreakoutStatus" AS ENUM ('DRAFT', 'ACTIVE', 'ENDED');
CREATE TYPE "DeliveryStatus" AS ENUM ('QUEUED', 'SENT', 'DELIVERED', 'FAILED');

ALTER TABLE "StaffMembership" ADD COLUMN "active" BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE "SchoolClass" ADD COLUMN "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE "SchoolClass" ADD COLUMN "updatedAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;
DROP INDEX "StudentReport_runId_studentId_key";
ALTER TABLE "StudentReport" ADD COLUMN "type" VARCHAR(40) NOT NULL DEFAULT 'FINAL';
ALTER TABLE "StudentReport" ADD COLUMN "version" INTEGER NOT NULL DEFAULT 1;
ALTER TABLE "StudentReport" ADD COLUMN "completedAt" TIMESTAMPTZ(3);
ALTER TABLE "StudentReport" ADD COLUMN "failureReason" TEXT;
CREATE UNIQUE INDEX "StudentReport_runId_studentId_type_version_key" ON "StudentReport"("runId", "studentId", "type", "version");

CREATE TABLE "MediaAsset" (
  "id" UUID NOT NULL, "schoolId" UUID, "storageKey" TEXT NOT NULL, "fileName" VARCHAR(300) NOT NULL,
  "mimeType" VARCHAR(150) NOT NULL, "sizeBytes" BIGINT NOT NULL, "checksum" VARCHAR(128) NOT NULL,
  "status" "FileStatus" NOT NULL DEFAULT 'PENDING', "uploadedById" UUID, "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "deletedAt" TIMESTAMPTZ(3), CONSTRAINT "MediaAsset_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "MediaAsset_storageKey_key" ON "MediaAsset"("storageKey");
CREATE INDEX "MediaAsset_schoolId_status_idx" ON "MediaAsset"("schoolId", "status");

CREATE TABLE "ImportBatch" (
  "id" UUID NOT NULL, "schoolId" UUID NOT NULL, "type" VARCHAR(60) NOT NULL, "status" "JobStatus" NOT NULL DEFAULT 'PENDING',
  "sourceAssetId" UUID NOT NULL, "requestedById" UUID NOT NULL, "totalRows" INTEGER NOT NULL DEFAULT 0,
  "validRows" INTEGER NOT NULL DEFAULT 0, "invalidRows" INTEGER NOT NULL DEFAULT 0, "importedRows" INTEGER NOT NULL DEFAULT 0,
  "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "completedAt" TIMESTAMPTZ(3), CONSTRAINT "ImportBatch_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "ImportBatch_schoolId_status_createdAt_idx" ON "ImportBatch"("schoolId", "status", "createdAt");

CREATE TABLE "ImportRow" (
  "id" UUID NOT NULL, "batchId" UUID NOT NULL, "rowNumber" INTEGER NOT NULL, "data" JSONB NOT NULL,
  "errors" JSONB, "valid" BOOLEAN NOT NULL, "importedAt" TIMESTAMPTZ(3), CONSTRAINT "ImportRow_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "ImportRow_batchId_rowNumber_key" ON "ImportRow"("batchId", "rowNumber");
ALTER TABLE "ImportRow" ADD CONSTRAINT "ImportRow_batchId_fkey" FOREIGN KEY ("batchId") REFERENCES "ImportBatch"("id") ON DELETE CASCADE ON UPDATE CASCADE;

CREATE TABLE "BackgroundJob" (
  "id" UUID NOT NULL, "schoolId" UUID, "queue" VARCHAR(80) NOT NULL, "type" VARCHAR(100) NOT NULL,
  "idempotencyKey" VARCHAR(200) NOT NULL, "payload" JSONB NOT NULL, "status" "JobStatus" NOT NULL DEFAULT 'PENDING',
  "attempts" INTEGER NOT NULL DEFAULT 0, "availableAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "completedAt" TIMESTAMPTZ(3), "failureReason" TEXT, "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "BackgroundJob_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "BackgroundJob_idempotencyKey_key" ON "BackgroundJob"("idempotencyKey");
CREATE INDEX "BackgroundJob_queue_status_availableAt_idx" ON "BackgroundJob"("queue", "status", "availableAt");
CREATE INDEX "BackgroundJob_schoolId_status_idx" ON "BackgroundJob"("schoolId", "status");

CREATE TABLE "RunStaffAssignment" (
  "id" UUID NOT NULL, "schoolId" UUID NOT NULL, "runId" UUID NOT NULL, "membershipId" UUID NOT NULL,
  "assignmentRole" VARCHAR(40) NOT NULL, "assignedById" UUID NOT NULL, "active" BOOLEAN NOT NULL DEFAULT true,
  "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, CONSTRAINT "RunStaffAssignment_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "RunStaffAssignment_runId_membershipId_assignmentRole_key" ON "RunStaffAssignment"("runId", "membershipId", "assignmentRole");
CREATE INDEX "RunStaffAssignment_schoolId_membershipId_active_idx" ON "RunStaffAssignment"("schoolId", "membershipId", "active");

CREATE TABLE "BreakoutRoom" (
  "id" UUID NOT NULL, "schoolId" UUID NOT NULL, "sessionId" UUID NOT NULL, "name" VARCHAR(120) NOT NULL,
  "providerRef" TEXT, "status" "BreakoutStatus" NOT NULL DEFAULT 'DRAFT', "position" INTEGER NOT NULL,
  "startedAt" TIMESTAMPTZ(3), "endedAt" TIMESTAMPTZ(3), CONSTRAINT "BreakoutRoom_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "BreakoutRoom_sessionId_position_key" ON "BreakoutRoom"("sessionId", "position");
CREATE INDEX "BreakoutRoom_schoolId_sessionId_status_idx" ON "BreakoutRoom"("schoolId", "sessionId", "status");

CREATE TABLE "BreakoutMembership" (
  "id" UUID NOT NULL, "schoolId" UUID NOT NULL, "roomId" UUID NOT NULL, "studentId" UUID NOT NULL,
  "joinedAt" TIMESTAMPTZ(3), "leftAt" TIMESTAMPTZ(3), CONSTRAINT "BreakoutMembership_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "BreakoutMembership_roomId_studentId_key" ON "BreakoutMembership"("roomId", "studentId");
CREATE INDEX "BreakoutMembership_schoolId_studentId_idx" ON "BreakoutMembership"("schoolId", "studentId");
ALTER TABLE "BreakoutMembership" ADD CONSTRAINT "BreakoutMembership_roomId_fkey" FOREIGN KEY ("roomId") REFERENCES "BreakoutRoom"("id") ON DELETE CASCADE ON UPDATE CASCADE;

CREATE TABLE "ActivitySubmission" (
  "id" UUID NOT NULL, "schoolId" UUID NOT NULL, "runId" UUID NOT NULL, "sessionId" UUID, "programItemId" UUID NOT NULL,
  "studentId" UUID NOT NULL, "status" "SubmissionStatus" NOT NULL DEFAULT 'DRAFT', "response" JSONB, "attachmentAssetId" UUID,
  "submittedAt" TIMESTAMPTZ(3), "gradedAt" TIMESTAMPTZ(3), "gradedById" UUID, "feedback" TEXT,
  "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "updatedAt" TIMESTAMPTZ(3) NOT NULL,
  CONSTRAINT "ActivitySubmission_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "ActivitySubmission_runId_programItemId_studentId_key" ON "ActivitySubmission"("runId", "programItemId", "studentId");
CREATE INDEX "ActivitySubmission_schoolId_studentId_status_idx" ON "ActivitySubmission"("schoolId", "studentId", "status");

CREATE TABLE "ProviderWebhookEvent" (
  "id" UUID NOT NULL, "provider" VARCHAR(60) NOT NULL, "externalId" VARCHAR(200) NOT NULL, "type" VARCHAR(100) NOT NULL,
  "payload" JSONB NOT NULL, "status" "JobStatus" NOT NULL DEFAULT 'PENDING', "receivedAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "processedAt" TIMESTAMPTZ(3), "failureReason" TEXT, CONSTRAINT "ProviderWebhookEvent_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "ProviderWebhookEvent_provider_externalId_key" ON "ProviderWebhookEvent"("provider", "externalId");
CREATE INDEX "ProviderWebhookEvent_status_receivedAt_idx" ON "ProviderWebhookEvent"("status", "receivedAt");

CREATE TABLE "NotificationDelivery" (
  "id" UUID NOT NULL, "notificationId" UUID NOT NULL, "channel" "NotificationChannel" NOT NULL, "destination" VARCHAR(320) NOT NULL,
  "status" "DeliveryStatus" NOT NULL DEFAULT 'QUEUED', "provider" VARCHAR(60), "providerMessageId" VARCHAR(200),
  "attempts" INTEGER NOT NULL DEFAULT 0, "nextAttemptAt" TIMESTAMPTZ(3), "sentAt" TIMESTAMPTZ(3), "deliveredAt" TIMESTAMPTZ(3),
  "failureReason" TEXT, CONSTRAINT "NotificationDelivery_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "NotificationDelivery_status_nextAttemptAt_idx" ON "NotificationDelivery"("status", "nextAttemptAt");
CREATE INDEX "NotificationDelivery_notificationId_idx" ON "NotificationDelivery"("notificationId");

CREATE TABLE "DevicePushToken" (
  "id" UUID NOT NULL, "studentId" UUID NOT NULL, "schoolId" UUID NOT NULL, "platform" VARCHAR(30) NOT NULL,
  "token" TEXT NOT NULL, "deviceId" VARCHAR(200), "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "revokedAt" TIMESTAMPTZ(3),
  CONSTRAINT "DevicePushToken_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "DevicePushToken_token_key" ON "DevicePushToken"("token");
CREATE INDEX "DevicePushToken_schoolId_studentId_revokedAt_idx" ON "DevicePushToken"("schoolId", "studentId", "revokedAt");

CREATE TABLE "ReportDelivery" (
  "id" UUID NOT NULL, "reportId" UUID NOT NULL, "guardianId" UUID NOT NULL, "email" VARCHAR(320) NOT NULL,
  "status" "DeliveryStatus" NOT NULL DEFAULT 'QUEUED', "sentAt" TIMESTAMPTZ(3), "failureReason" TEXT,
  CONSTRAINT "ReportDelivery_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "ReportDelivery_reportId_status_idx" ON "ReportDelivery"("reportId", "status");

CREATE TABLE "CmsNavigation" (
  "id" UUID NOT NULL, "key" VARCHAR(80) NOT NULL, "name" VARCHAR(120) NOT NULL, "updatedAt" TIMESTAMPTZ(3) NOT NULL,
  CONSTRAINT "CmsNavigation_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "CmsNavigation_key_key" ON "CmsNavigation"("key");
CREATE TABLE "CmsNavigationItem" (
  "id" UUID NOT NULL, "navigationId" UUID NOT NULL, "label" VARCHAR(120) NOT NULL, "url" VARCHAR(500) NOT NULL, "position" INTEGER NOT NULL,
  CONSTRAINT "CmsNavigationItem_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "CmsNavigationItem_navigationId_position_key" ON "CmsNavigationItem"("navigationId", "position");
ALTER TABLE "CmsNavigationItem" ADD CONSTRAINT "CmsNavigationItem_navigationId_fkey" FOREIGN KEY ("navigationId") REFERENCES "CmsNavigation"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "MediaAsset" ADD CONSTRAINT "MediaAsset_schoolId_fkey" FOREIGN KEY ("schoolId") REFERENCES "School"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "MediaAsset" ADD CONSTRAINT "MediaAsset_uploadedById_fkey" FOREIGN KEY ("uploadedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "ImportBatch" ADD CONSTRAINT "ImportBatch_schoolId_fkey" FOREIGN KEY ("schoolId") REFERENCES "School"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "ImportBatch" ADD CONSTRAINT "ImportBatch_sourceAssetId_fkey" FOREIGN KEY ("sourceAssetId") REFERENCES "MediaAsset"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "ImportBatch" ADD CONSTRAINT "ImportBatch_requestedById_fkey" FOREIGN KEY ("requestedById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "BackgroundJob" ADD CONSTRAINT "BackgroundJob_schoolId_fkey" FOREIGN KEY ("schoolId") REFERENCES "School"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "RunStaffAssignment" ADD CONSTRAINT "RunStaffAssignment_runId_fkey" FOREIGN KEY ("runId") REFERENCES "ProgramRun"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "RunStaffAssignment" ADD CONSTRAINT "RunStaffAssignment_membershipId_fkey" FOREIGN KEY ("membershipId") REFERENCES "StaffMembership"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "RunStaffAssignment" ADD CONSTRAINT "RunStaffAssignment_assignedById_fkey" FOREIGN KEY ("assignedById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "BreakoutRoom" ADD CONSTRAINT "BreakoutRoom_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "LearningSession"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "BreakoutMembership" ADD CONSTRAINT "BreakoutMembership_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "Student"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "ActivitySubmission" ADD CONSTRAINT "ActivitySubmission_runId_fkey" FOREIGN KEY ("runId") REFERENCES "ProgramRun"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ActivitySubmission" ADD CONSTRAINT "ActivitySubmission_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "LearningSession"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "ActivitySubmission" ADD CONSTRAINT "ActivitySubmission_programItemId_fkey" FOREIGN KEY ("programItemId") REFERENCES "ProgramItem"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "ActivitySubmission" ADD CONSTRAINT "ActivitySubmission_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "Student"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "ActivitySubmission" ADD CONSTRAINT "ActivitySubmission_attachmentAssetId_fkey" FOREIGN KEY ("attachmentAssetId") REFERENCES "MediaAsset"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "ActivitySubmission" ADD CONSTRAINT "ActivitySubmission_gradedById_fkey" FOREIGN KEY ("gradedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "NotificationDelivery" ADD CONSTRAINT "NotificationDelivery_notificationId_fkey" FOREIGN KEY ("notificationId") REFERENCES "Notification"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "DevicePushToken" ADD CONSTRAINT "DevicePushToken_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "Student"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ReportDelivery" ADD CONSTRAINT "ReportDelivery_reportId_fkey" FOREIGN KEY ("reportId") REFERENCES "StudentReport"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ReportDelivery" ADD CONSTRAINT "ReportDelivery_guardianId_fkey" FOREIGN KEY ("guardianId") REFERENCES "Guardian"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "MediaAsset" ADD CONSTRAINT "MediaAsset_size_check" CHECK ("sizeBytes" >= 0);
ALTER TABLE "ImportBatch" ADD CONSTRAINT "ImportBatch_counts_check" CHECK ("totalRows" >= 0 AND "validRows" >= 0 AND "invalidRows" >= 0 AND "importedRows" >= 0);
ALTER TABLE "BackgroundJob" ADD CONSTRAINT "BackgroundJob_attempts_check" CHECK ("attempts" >= 0);
ALTER TABLE "BreakoutRoom" ADD CONSTRAINT "BreakoutRoom_dates_check" CHECK ("endedAt" IS NULL OR "startedAt" IS NULL OR "endedAt" >= "startedAt");
ALTER TABLE "BreakoutMembership" ADD CONSTRAINT "BreakoutMembership_dates_check" CHECK ("leftAt" IS NULL OR "joinedAt" IS NULL OR "leftAt" >= "joinedAt");
