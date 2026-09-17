import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { StudentStatus } from '@prisma/client';
import { hash } from 'argon2';
import { createHmac, randomInt } from 'node:crypto';
import { AuditService } from '../audit/audit.service';
import { Principal } from '../common/principal';
import { TenantAccessService } from '../common/tenant-access.service';
import { PrismaService } from '../database/prisma.service';
import { CreateStudentDto } from './students.dto';

const CODE_ALPHABET = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';

@Injectable()
export class StudentsService {
  constructor(private readonly prisma: PrismaService, private readonly access: TenantAccessService, private readonly config: ConfigService, private readonly audit: AuditService) {}

  private lookup(schoolId: string, code: string): string {
    return createHmac('sha256', this.config.getOrThrow<string>('STUDENT_CODE_PEPPER')).update(`${schoolId}:${code}`).digest('hex');
  }

  private newCode(): string {
    return Array.from({ length: 6 }, () => CODE_ALPHABET[randomInt(CODE_ALPHABET.length)]).join('');
  }

  async create(schoolId: string, dto: CreateStudentDto, principal: Principal) {
    this.access.assertSchool(principal, schoolId);
    if (dto.classId) {
      const schoolClass = await this.prisma.schoolClass.findFirst({ where: { id: dto.classId, schoolId, active: true } });
      if (!schoolClass) throw new NotFoundException('Class not found in this school');
    }
    const code = this.newCode();
    const codeLookup = this.lookup(schoolId, code);
    if (await this.prisma.studentAccessCredential.findUnique({ where: { codeLookup } })) throw new ConflictException('Unable to allocate a unique access code');
    const student = await this.prisma.$transaction(async (tx) => {
      const created = await tx.student.create({ data: { schoolId, name: dto.name.trim(), grade: dto.grade.trim() } });
      await tx.studentAccessCredential.create({ data: { schoolId, studentId: created.id, codeHash: await hash(code), codeLookup, codeHint: code.slice(-2) } });
      if (dto.classId) await tx.classStudent.create({ data: { schoolId, classId: dto.classId, studentId: created.id } });
      if (dto.guardian) {
        const guardian = await tx.guardian.create({ data: { schoolId, name: dto.guardian.name.trim(), email: dto.guardian.email.trim().toLowerCase() } });
        await tx.studentGuardian.create({ data: { schoolId, studentId: created.id, guardianId: guardian.id, relationship: dto.guardian.relationship, receiveSessionSummaries: dto.guardian.receiveSessionSummaries ?? true, receiveFinalReports: dto.guardian.receiveFinalReports ?? true } });
      }
      return created;
    });
    await this.audit.write({ schoolId, actorUserId: principal.sub, action: 'STUDENT_CREATED', entityType: 'Student', entityId: student.id });
    return { ...student, accessCode: code };
  }

  async list(schoolId: string, principal: Principal, cursor?: string) {
    this.access.assertSchool(principal, schoolId);
    return this.prisma.student.findMany({
      where: { schoolId }, take: 51, ...(cursor ? { cursor: { id: cursor }, skip: 1 } : {}), orderBy: { id: 'asc' },
      select: { id: true, name: true, grade: true, status: true, credential: { select: { codeHint: true, revokedAt: true } }, guardians: { select: { relationship: true, guardian: { select: { id: true, name: true, email: true } } } }, classes: { select: { class: { select: { id: true, name: true } } } } },
    });
  }

  async get(schoolId: string, studentId: string, principal: Principal) {
    this.access.assertSchool(principal, schoolId);
    const student = await this.prisma.student.findFirst({ where: { id: studentId, schoolId }, include: { guardians: { include: { guardian: true } }, classes: { include: { class: true } } } });
    if (!student) throw new NotFoundException('Student not found');
    return student;
  }

  async regenerateCode(schoolId: string, studentId: string, principal: Principal) {
    this.access.assertSchool(principal, schoolId);
    const student = await this.prisma.student.findFirst({ where: { id: studentId, schoolId } });
    if (!student) throw new NotFoundException('Student not found');
    const code = this.newCode();
    await this.prisma.$transaction([
      this.prisma.studentAccessCredential.upsert({ where: { studentId }, create: { schoolId, studentId, codeHash: await hash(code), codeLookup: this.lookup(schoolId, code), codeHint: code.slice(-2) }, update: { codeHash: await hash(code), codeLookup: this.lookup(schoolId, code), codeHint: code.slice(-2), revokedAt: null, generatedAt: new Date() } }),
      this.prisma.studentSession.updateMany({ where: { schoolId, studentId, revokedAt: null }, data: { revokedAt: new Date() } }),
    ]);
    await this.audit.write({ schoolId, actorUserId: principal.sub, action: 'STUDENT_ACCESS_CODE_REGENERATED', entityType: 'Student', entityId: studentId });
    return { studentId, accessCode: code };
  }

  async disable(schoolId: string, studentId: string, principal: Principal) {
    this.access.assertSchool(principal, schoolId);
    const result = await this.prisma.$transaction(async (tx) => {
      const updated = await tx.student.updateMany({ where: { id: studentId, schoolId }, data: { status: StudentStatus.DISABLED } });
      if (!updated.count) throw new NotFoundException('Student not found');
      await tx.studentSession.updateMany({ where: { schoolId, studentId, revokedAt: null }, data: { revokedAt: new Date() } });
      await tx.studentAccessCredential.updateMany({ where: { schoolId, studentId, revokedAt: null }, data: { revokedAt: new Date() } });
      return { success: true };
    });
    await this.audit.write({ schoolId, actorUserId: principal.sub, action: 'STUDENT_DISABLED', entityType: 'Student', entityId: studentId });
    return result;
  }
}
