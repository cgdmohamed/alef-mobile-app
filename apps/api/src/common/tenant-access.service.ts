import { ForbiddenException, Injectable } from '@nestjs/common';
import { StaffRole } from '@prisma/client';
import { Principal } from './principal';

@Injectable()
export class TenantAccessService {
  assertSchool(principal: Principal, schoolId: string): void {
    if (principal.kind === 'student') {
      if (principal.schoolId !== schoolId) throw new ForbiddenException('Cross-school access denied');
      return;
    }
    const global = principal.roles.some(({ role }) => role === StaffRole.ALIF_SUPER_ADMIN || role === StaffRole.PROGRAM_MANAGER);
    const member = principal.roles.some((membership) => membership.schoolId === schoolId);
    if (!global && !member) throw new ForbiddenException('Cross-school access denied');
  }
}
