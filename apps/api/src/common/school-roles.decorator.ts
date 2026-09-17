import { SetMetadata } from '@nestjs/common';
import { StaffRole } from '@prisma/client';

export const SCHOOL_ROLES_KEY = 'schoolRoles';
export const SchoolRoles = (...roles: StaffRole[]) => SetMetadata(SCHOOL_ROLES_KEY, roles);
