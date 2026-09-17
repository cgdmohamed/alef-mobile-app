import { ExecutionContext, ForbiddenException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { StaffRole } from '@prisma/client';
import { SchoolRolesGuard } from '../src/common/school-roles.guard';

describe('SchoolRolesGuard', () => {
  const reflector = { getAllAndOverride: jest.fn() } as unknown as Reflector;
  const guard = new SchoolRolesGuard(reflector);
  const context = (user: unknown, schoolId = 'school-b') => ({
    getHandler: () => null,
    getClass: () => null,
    switchToHttp: () => ({ getRequest: () => ({ user, params: { schoolId } }) }),
  }) as unknown as ExecutionContext;

  beforeEach(() => jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue([StaffRole.SCHOOL_ADMIN]));

  it('does not compose an admin role from another school', () => {
    const user = { kind: 'staff', sub: 'u', sessionId: 's', roles: [{ id: 'm1', role: StaffRole.SCHOOL_ADMIN, schoolId: 'school-a' }, { id: 'm2', role: StaffRole.TALENT_SPECIALIST, schoolId: 'school-b' }] };
    expect(() => guard.canActivate(context(user))).toThrow(ForbiddenException);
  });

  it('accepts the required role in the requested school', () => {
    const user = { kind: 'staff', sub: 'u', sessionId: 's', roles: [{ id: 'm1', role: StaffRole.SCHOOL_ADMIN, schoolId: 'school-b' }] };
    expect(guard.canActivate(context(user))).toBe(true);
  });
});
