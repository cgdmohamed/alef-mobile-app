import { BadRequestException, ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { ProgramVersionStatus } from '@prisma/client';
import { AuditService } from '../audit/audit.service';
import { Principal } from '../common/principal';
import { TenantAccessService } from '../common/tenant-access.service';
import { EntitlementsService } from '../common/entitlements.service';
import { PrismaService } from '../database/prisma.service';
import { CreateRunDto, EnrollStudentsDto, RunStatusDto, ScheduleSessionsDto } from './runs.dto';

@Injectable()
export class RunsService {
  constructor(private readonly prisma: PrismaService, private readonly access: TenantAccessService, private readonly audit: AuditService, private readonly entitlements: EntitlementsService) {}

  async create(schoolId: string, dto: CreateRunDto, principal: Principal) {
    this.access.assertSchool(principal, schoolId);
    await this.entitlements.limit(schoolId, 'max_active_programs');
    const startsAt = new Date(dto.startsAt); const endsAt = new Date(dto.endsAt);
    if (startsAt >= endsAt) throw new BadRequestException('Run end must be after start');
    const version = await this.prisma.programVersion.findFirst({ where: { id: dto.programVersionId, status: ProgramVersionStatus.PUBLISHED } });
    if (!version) throw new NotFoundException('Published program version not found');
    for (const membershipId of [dto.trainerMembershipId, dto.specialistMembershipId].filter(Boolean) as string[]) {
      const membership = await this.prisma.staffMembership.findFirst({ where: { id: membershipId, OR: [{ schoolId }, { schoolId: null }] } });
      if (!membership) throw new BadRequestException('Assigned staff member is not available to this school');
    }
    const run = await this.prisma.programRun.create({ data: { schoolId, programVersionId: dto.programVersionId, name: dto.name.trim(), academicTerm: dto.academicTerm, trainerMembershipId: dto.trainerMembershipId, specialistMembershipId: dto.specialistMembershipId, startsAt, endsAt, recordingRetentionDays: dto.recordingRetentionDays ?? 30 } });
    await this.audit.write({ schoolId, actorUserId: principal.sub, action: 'PROGRAM_RUN_CREATED', entityType: 'ProgramRun', entityId: run.id });
    return run;
  }

  async list(schoolId: string, principal: Principal) {
    this.access.assertSchool(principal, schoolId);
    return this.prisma.programRun.findMany({ where: { schoolId }, include: { programVersion: { select: { version: true, program: { select: { id: true, title: true } } } }, _count: { select: { enrollments: true, sessions: true } } }, orderBy: { startsAt: 'desc' } });
  }

  async enroll(schoolId: string, runId: string, dto: EnrollStudentsDto, principal: Principal) {
    this.access.assertSchool(principal, schoolId);
    const run = await this.prisma.programRun.findFirst({ where: { id: runId, schoolId } });
    if (!run) throw new NotFoundException('Program run not found');
    const uniqueIds = [...new Set(dto.studentIds)];
    const count = await this.prisma.student.count({ where: { id: { in: uniqueIds }, schoolId, status: 'ACTIVE' } });
    if (count !== uniqueIds.length) throw new BadRequestException('One or more students do not belong to this school');
    const result = await this.prisma.enrollment.createMany({ data: uniqueIds.map((studentId) => ({ schoolId, runId, studentId })), skipDuplicates: true });
    await this.audit.write({ schoolId, actorUserId: principal.sub, action: 'ENROLLMENTS_ADDED', entityType: 'ProgramRun', entityId: runId, metadata: { studentIds: uniqueIds } });
    return { enrolled: result.count };
  }

  async schedule(schoolId: string, runId: string, dto: ScheduleSessionsDto, principal: Principal) {
    this.access.assertSchool(principal, schoolId);
    const run = await this.prisma.programRun.findFirst({ where: { id: runId, schoolId } });
    if (!run) throw new NotFoundException('Program run not found');
    const sessions = dto.sessions.map((session) => ({ ...session, start: new Date(session.scheduledStart), end: new Date(session.scheduledEnd) }));
    if (sessions.some(({ start, end }) => start >= end || start < run.startsAt || end > run.endsAt)) throw new BadRequestException('Session schedule must fall within the run dates');
    const duplicate = sessions.some((session, index) => sessions.some((other, otherIndex) => index !== otherIndex && session.start < other.end && session.end > other.start));
    if (duplicate) throw new ConflictException('Sessions cannot overlap within a run');
    await this.prisma.learningSession.createMany({ data: sessions.map(({ title, start, end }) => ({ schoolId, runId, title, scheduledStart: start, scheduledEnd: end })) });
    return this.prisma.learningSession.findMany({ where: { schoolId, runId }, orderBy: { scheduledStart: 'asc' } });
  }
  async transition(schoolId: string, runId: string, dto: RunStatusDto, principal: Principal) { this.access.assertSchool(principal, schoolId); const run = await this.prisma.programRun.findFirst({ where: { id: runId, schoolId } }); if (!run) throw new NotFoundException('Program run not found'); const allowed: Record<string, string[]> = { DRAFT: ['SCHEDULED', 'CANCELLED'], SCHEDULED: ['ACTIVE', 'CANCELLED'], ACTIVE: ['COMPLETED', 'CANCELLED'] }; if (!allowed[run.status]?.includes(dto.status)) throw new BadRequestException(`Invalid run transition from ${run.status} to ${dto.status}`); if (dto.status === 'SCHEDULED' || dto.status === 'ACTIVE') await this.entitlements.assertActiveProgramCapacity(schoolId, runId); return this.prisma.$transaction(async (tx) => { const updated = await tx.programRun.update({ where: { id: runId }, data: { status: dto.status } }); await tx.auditLog.create({ data: { schoolId, actorUserId: principal.sub, action: 'PROGRAM_RUN_STATUS_CHANGED', entityType: 'ProgramRun', entityId: runId, before: { status: run.status }, after: { status: dto.status } } }); return updated; }); }
}
