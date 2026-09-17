import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { SchoolStatus, StudentStatus, UserStatus } from '@prisma/client';
import { hash, verify } from 'argon2';
import { createHash, createHmac, randomBytes, randomUUID } from 'node:crypto';
import { AuditService } from '../audit/audit.service';
import { Principal, StaffPrincipal, StudentPrincipal } from '../common/principal';
import { PrismaService } from '../database/prisma.service';
import { StaffLoginDto, StudentLoginDto } from './auth.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
    private readonly audit: AuditService,
  ) {}

  private digest(value: string): string {
    return createHash('sha256').update(value).digest('hex');
  }

  private studentLookup(schoolId: string, code: string): string {
    return createHmac('sha256', this.config.getOrThrow<string>('STUDENT_CODE_PEPPER'))
      .update(`${schoolId}:${code.toUpperCase()}`)
      .digest('hex');
  }

  private async accessToken(principal: Principal): Promise<string> {
    return this.jwt.signAsync(principal, { expiresIn: this.config.getOrThrow<number>('JWT_ACCESS_TTL_SECONDS') });
  }

  private newRefreshToken(): string {
    return randomBytes(48).toString('base64url');
  }

  async staffLogin(dto: StaffLoginDto, ipAddress?: string, userAgent?: string) {
    const user = await this.prisma.user.findUnique({
      where: { email: dto.email.trim().toLowerCase() },
      include: { memberships: true },
    });
    if (!user?.passwordHash || user.status !== UserStatus.ACTIVE || !(await verify(user.passwordHash, dto.password))) {
      throw new UnauthorizedException('Invalid credentials');
    }
    const refreshToken = this.newRefreshToken();
    const days = this.config.getOrThrow<number>('REFRESH_TOKEN_DAYS');
    const [session] = await this.prisma.$transaction([
      this.prisma.refreshSession.create({
        data: {
          userId: user.id,
          tokenHash: this.digest(refreshToken),
          familyId: randomUUID(),
          expiresAt: new Date(Date.now() + days * 86_400_000),
          ipAddress,
          userAgent,
        },
      }),
      this.prisma.user.update({ where: { id: user.id }, data: { lastLoginAt: new Date() } }),
    ]);
    const principal: StaffPrincipal = {
      kind: 'staff',
      sub: user.id,
      sessionId: session.id,
      roles: user.memberships.map(({ id, role, schoolId }) => ({ id, role, schoolId })),
    };
    await this.audit.write({ actorUserId: user.id, action: 'AUTH_LOGIN', entityType: 'User', entityId: user.id });
    return { accessToken: await this.accessToken(principal), refreshToken, user: { id: user.id, name: user.name, email: user.email, roles: principal.roles } };
  }

  async studentLogin(dto: StudentLoginDto) {
    const school = await this.prisma.school.findUnique({ where: { code: dto.schoolCode.trim().toUpperCase() } });
    if (!school || school.status !== SchoolStatus.ACTIVE) throw new UnauthorizedException('Invalid school or access code');
    const credential = await this.prisma.studentAccessCredential.findUnique({
      where: { codeLookup: this.studentLookup(school.id, dto.accessCode.trim()) },
      include: { student: true },
    });
    if (!credential || credential.schoolId !== school.id || credential.revokedAt || credential.student.status !== StudentStatus.ACTIVE || !(await verify(credential.codeHash, dto.accessCode.trim().toUpperCase()))) {
      throw new UnauthorizedException('Invalid school or access code');
    }
    const refreshToken = this.newRefreshToken();
    const days = this.config.getOrThrow<number>('REFRESH_TOKEN_DAYS');
    const session = await this.prisma.studentSession.create({
      data: { schoolId: school.id, studentId: credential.studentId, tokenHash: this.digest(refreshToken), expiresAt: new Date(Date.now() + days * 86_400_000), deviceId: dto.deviceId },
    });
    const principal: StudentPrincipal = { kind: 'student', sub: credential.studentId, schoolId: school.id, sessionId: session.id };
    await this.audit.write({ schoolId: school.id, action: 'STUDENT_AUTH_LOGIN', entityType: 'Student', entityId: credential.studentId });
    return { accessToken: await this.accessToken(principal), refreshToken, student: { id: credential.student.id, name: credential.student.name, school: { id: school.id, name: school.name } } };
  }

  async refresh(kind: 'staff' | 'student', rawToken: string) {
    const tokenHash = this.digest(rawToken);
    const replacement = this.newRefreshToken();
    const expiresAt = new Date(Date.now() + this.config.getOrThrow<number>('REFRESH_TOKEN_DAYS') * 86_400_000);
    if (kind === 'staff') {
      return this.prisma.$transaction(async (tx) => {
        const current = await tx.refreshSession.findUnique({ where: { tokenHash }, include: { user: { include: { memberships: true } } } });
        if (current?.revokedAt) {
          await tx.refreshSession.updateMany({ where: { familyId: current.familyId, revokedAt: null }, data: { revokedAt: new Date() } });
          throw new UnauthorizedException('Refresh token reuse detected');
        }
        if (!current || current.expiresAt <= new Date() || current.user.status !== UserStatus.ACTIVE) throw new UnauthorizedException('Invalid refresh token');
        const revoked = await tx.refreshSession.updateMany({ where: { id: current.id, revokedAt: null }, data: { revokedAt: new Date() } });
        if (revoked.count !== 1) throw new UnauthorizedException('Refresh token was already used');
        const next = await tx.refreshSession.create({ data: { userId: current.userId, tokenHash: this.digest(replacement), familyId: current.familyId, expiresAt } });
        await tx.refreshSession.update({ where: { id: current.id }, data: { replacedById: next.id } });
        const principal: StaffPrincipal = { kind: 'staff', sub: current.userId, sessionId: next.id, roles: current.user.memberships.map(({ id, role, schoolId }) => ({ id, role, schoolId })) };
        return { accessToken: await this.accessToken(principal), refreshToken: replacement };
      });
    }
    return this.prisma.$transaction(async (tx) => {
      const current = await tx.studentSession.findUnique({ where: { tokenHash }, include: { student: true } });
      if (!current || current.revokedAt || current.expiresAt <= new Date() || current.student.status !== StudentStatus.ACTIVE) throw new UnauthorizedException('Invalid refresh token');
      const rotated = await tx.studentSession.updateMany({ where: { id: current.id, tokenHash, revokedAt: null }, data: { tokenHash: this.digest(replacement), expiresAt } });
      if (rotated.count !== 1) throw new UnauthorizedException('Refresh token was already used');
      const principal: StudentPrincipal = { kind: 'student', sub: current.studentId, schoolId: current.schoolId, sessionId: current.id };
      return { accessToken: await this.accessToken(principal), refreshToken: replacement };
    });
  }

  async logout(kind: 'staff' | 'student', rawToken: string): Promise<void> {
    const tokenHash = this.digest(rawToken);
    if (kind === 'staff') await this.prisma.refreshSession.updateMany({ where: { tokenHash, revokedAt: null }, data: { revokedAt: new Date() } });
    else await this.prisma.studentSession.updateMany({ where: { tokenHash, revokedAt: null }, data: { revokedAt: new Date() } });
  }

  async me(principal: Principal) {
    if (principal.kind === 'student') {
      return this.prisma.student.findFirstOrThrow({ where: { id: principal.sub, schoolId: principal.schoolId }, select: { id: true, name: true, grade: true, status: true, school: { select: { id: true, name: true, code: true } } } });
    }
    return this.prisma.user.findUniqueOrThrow({ where: { id: principal.sub }, select: { id: true, name: true, email: true, status: true, memberships: { select: { role: true, schoolId: true, canTrain: true } } } });
  }

  async createStudentCredential(schoolId: string, studentId: string, plainCode: string) {
    const normalized = plainCode.toUpperCase();
    return this.prisma.studentAccessCredential.create({ data: { schoolId, studentId, codeHash: await hash(normalized), codeLookup: this.studentLookup(schoolId, normalized), codeHint: normalized.slice(-2) } });
  }
}
