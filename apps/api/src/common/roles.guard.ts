import { CanActivate, ExecutionContext, ForbiddenException, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { StaffRole } from '@prisma/client';
import { Principal } from './principal';
import { ROLES_KEY } from './roles.decorator';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const required = this.reflector.getAllAndOverride<StaffRole[]>(ROLES_KEY, [context.getHandler(), context.getClass()]);
    if (!required?.length) return true;
    const principal = context.switchToHttp().getRequest<{ user: Principal }>().user;
    if (principal.kind !== 'staff' || !principal.roles.some(({ role }) => required.includes(role))) {
      throw new ForbiddenException('Insufficient permissions');
    }
    return true;
  }
}
