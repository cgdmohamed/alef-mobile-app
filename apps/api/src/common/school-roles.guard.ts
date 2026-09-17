import { CanActivate, ExecutionContext, ForbiddenException, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { StaffRole } from '@prisma/client';
import { Principal } from './principal';
import { SCHOOL_ROLES_KEY } from './school-roles.decorator';

@Injectable()
export class SchoolRolesGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const required = this.reflector.getAllAndOverride<StaffRole[]>(SCHOOL_ROLES_KEY, [context.getHandler(), context.getClass()]);
    if (!required?.length) return true;
    const request = context.switchToHttp().getRequest<{ user: Principal; params: { schoolId?: string } }>();
    const schoolId = request.params.schoolId;
    if (!schoolId || request.user.kind !== 'staff') throw new ForbiddenException('School-scoped staff access required');
    const global = request.user.roles.some(({ role, schoolId: scope }) => scope === null && role === StaffRole.ALIF_SUPER_ADMIN);
    const scoped = request.user.roles.some(({ role, schoolId: scope }) => scope === schoolId && required.includes(role));
    if (!global && !scoped) throw new ForbiddenException('Insufficient permissions for this school');
    return true;
  }
}
