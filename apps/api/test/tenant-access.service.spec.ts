import { ForbiddenException } from '@nestjs/common';
import { StaffRole } from '@prisma/client';
import { TenantAccessService } from '../src/common/tenant-access.service';

describe('TenantAccessService', () => {
  const access = new TenantAccessService();

  it('rejects a school user accessing another school', () => {
    expect(() => access.assertSchool({ kind: 'staff', sub: 'user-1', sessionId: 'session-1', roles: [{ role: StaffRole.SCHOOL_ADMIN, schoolId: 'school-a' }] }, 'school-b')).toThrow(ForbiddenException);
  });

  it('allows only the owning school for students', () => {
    expect(() => access.assertSchool({ kind: 'student', sub: 'student-1', schoolId: 'school-a', sessionId: 'session-1' }, 'school-b')).toThrow(ForbiddenException);
    expect(() => access.assertSchool({ kind: 'student', sub: 'student-1', schoolId: 'school-a', sessionId: 'session-1' }, 'school-a')).not.toThrow();
  });

  it('allows global Alif administrators', () => {
    expect(() => access.assertSchool({ kind: 'staff', sub: 'admin-1', sessionId: 'session-1', roles: [{ role: StaffRole.ALIF_SUPER_ADMIN, schoolId: null }] }, 'school-b')).not.toThrow();
  });
});
