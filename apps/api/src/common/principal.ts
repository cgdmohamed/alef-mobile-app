import { StaffRole } from '@prisma/client';

export type StaffPrincipal = {
  kind: 'staff';
  sub: string;
  sessionId: string;
  roles: Array<{ id: string; role: StaffRole; schoolId: string | null }>;
};

export type StudentPrincipal = {
  kind: 'student';
  sub: string;
  schoolId: string;
  sessionId: string;
};

export type Principal = StaffPrincipal | StudentPrincipal;
