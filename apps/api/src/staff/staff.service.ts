import { BadRequestException, ConflictException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { StaffRole, UserStatus } from '@prisma/client';
import { hash } from 'argon2';
import { Principal } from '../common/principal';
import { TenantAccessService } from '../common/tenant-access.service';
import { PrismaService } from '../database/prisma.service';
import { CreateStaffDto, SchoolStaffDto } from './staff.dto';

@Injectable()
export class StaffService {
  constructor(private readonly prisma: PrismaService, private readonly access: TenantAccessService) {}

  private async createMembership(dto: CreateStaffDto, actor: Principal) {
    const globalRole = dto.role === StaffRole.ALIF_SUPER_ADMIN || dto.role === StaffRole.PROGRAM_MANAGER || dto.role === StaffRole.ALIF_TRAINER;
    if (globalRole === !!dto.schoolId) throw new BadRequestException(globalRole ? 'Global role cannot have a school' : 'School role requires a school');
    return this.prisma.$transaction(async (tx) => {
      const email = dto.email.trim().toLowerCase();
      let user = await tx.user.findUnique({ where: { email } });
      if (!user) user = await tx.user.create({ data: { email, name: dto.name.trim(), passwordHash: await hash(dto.password) } });
      else if (user.status !== UserStatus.ACTIVE) throw new ConflictException('User is disabled');
      const duplicate = await tx.staffMembership.findFirst({ where: { userId: user.id, schoolId: dto.schoolId ?? null, role: dto.role, active: true } });
      if (duplicate) throw new ConflictException('Staff membership already exists');
      const membership = await tx.staffMembership.create({ data: { userId: user.id, schoolId: dto.schoolId, role: dto.role, canTrain: dto.canTrain ?? false } });
      await tx.auditLog.create({ data: { schoolId: dto.schoolId, actorUserId: actor.sub, action: 'STAFF_MEMBERSHIP_CREATED', entityType: 'StaffMembership', entityId: membership.id } });
      return { id: user.id, email: user.email, name: user.name, membership };
    });
  }

  createGlobal(dto: CreateStaffDto, actor: Principal) { return this.createMembership(dto, actor); }
  createSchool(schoolId: string, dto: SchoolStaffDto, actor: Principal) {
    this.access.assertSchool(actor, schoolId);
    if (dto.role !== StaffRole.TALENT_SPECIALIST && dto.role !== StaffRole.SCHOOL_ADMIN) throw new BadRequestException('Invalid school role');
    if (actor.kind !== 'staff') throw new ForbiddenException();
    const isSuper = actor.roles.some((r) => r.role === StaffRole.ALIF_SUPER_ADMIN);
    const isAdmin = actor.roles.some((r) => r.schoolId === schoolId && r.role === StaffRole.SCHOOL_ADMIN);
    if (!isSuper && (!isAdmin || dto.role === StaffRole.SCHOOL_ADMIN)) throw new ForbiddenException('Only Alif administrators can assign school administrators');
    return this.createMembership({ ...dto, schoolId }, actor);
  }
  async list(schoolId: string, actor: Principal) { this.access.assertSchool(actor, schoolId); return this.prisma.staffMembership.findMany({ where: { schoolId, active: true }, select: { id: true, role: true, canTrain: true, createdAt: true, user: { select: { id: true, name: true, email: true, status: true } } } }); }
  async revoke(schoolId: string, membershipId: string, actor: Principal) { this.access.assertSchool(actor, schoolId); const membership = await this.prisma.staffMembership.findFirst({ where: { id: membershipId, schoolId, active: true } }); if (!membership) throw new NotFoundException('Membership not found'); await this.prisma.$transaction([this.prisma.staffMembership.update({ where: { id: membershipId }, data: { active: false } }), this.prisma.refreshSession.updateMany({ where: { userId: membership.userId, revokedAt: null }, data: { revokedAt: new Date() } }), this.prisma.auditLog.create({ data: { schoolId, actorUserId: actor.sub, action: 'STAFF_MEMBERSHIP_REVOKED', entityType: 'StaffMembership', entityId: membershipId } })]); return { success: true }; }
  async disable(userId: string, actor: Principal) { const user = await this.prisma.user.findUnique({ where: { id: userId } }); if (!user) throw new NotFoundException('User not found'); await this.prisma.$transaction([this.prisma.user.update({ where: { id: userId }, data: { status: UserStatus.DISABLED, tokenVersion: { increment: 1 } } }), this.prisma.refreshSession.updateMany({ where: { userId, revokedAt: null }, data: { revokedAt: new Date() } }), this.prisma.auditLog.create({ data: { actorUserId: actor.sub, action: 'STAFF_DISABLED', entityType: 'User', entityId: userId } })]); return { success: true }; }
}
