CREATE TABLE "SessionAudioPermission" (
  "id" UUID NOT NULL,
  "schoolId" UUID NOT NULL,
  "sessionId" UUID NOT NULL,
  "studentId" UUID NOT NULL,
  "allowed" BOOLEAN NOT NULL DEFAULT false,
  "grantedById" UUID,
  "updatedAt" TIMESTAMPTZ(3) NOT NULL,
  CONSTRAINT "SessionAudioPermission_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "SessionAudioPermission_sessionId_studentId_key" ON "SessionAudioPermission"("sessionId", "studentId");
CREATE INDEX "SessionAudioPermission_schoolId_studentId_idx" ON "SessionAudioPermission"("schoolId", "studentId");
ALTER TABLE "SessionAudioPermission" ADD CONSTRAINT "SessionAudioPermission_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "LearningSession"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "SessionAudioPermission" ADD CONSTRAINT "SessionAudioPermission_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "Student"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "SessionAudioPermission" ADD CONSTRAINT "SessionAudioPermission_grantedById_fkey" FOREIGN KEY ("grantedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
