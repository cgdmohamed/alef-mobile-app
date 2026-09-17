import { CanActivate, ExecutionContext, Injectable, UnauthorizedException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { JwtService } from '@nestjs/jwt';
import { IS_PUBLIC_KEY } from './public.decorator';
import { Principal } from './principal';
import { PrismaService } from '../database/prisma.service';

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(private readonly reflector: Reflector, private readonly jwt: JwtService, private readonly prisma: PrismaService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    if (this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [context.getHandler(), context.getClass()])) return true;
    const request = context.switchToHttp().getRequest<{ headers: { authorization?: string }; user?: Principal }>();
    const [type, token] = request.headers.authorization?.split(' ') ?? [];
    if (type !== 'Bearer' || !token) throw new UnauthorizedException('Authentication required');
    try {
      const principal = await this.jwt.verifyAsync<Principal>(token);
      if (principal.kind === 'staff') {
        const active = await this.prisma.refreshSession.findFirst({ where: { id: principal.sessionId, userId: principal.sub, revokedAt: null, expiresAt: { gt: new Date() }, user: { status: 'ACTIVE' } }, select: { user: { select: { memberships: { select: { role: true, schoolId: true, school: { select: { status: true } } } } } } } });
        if (!active) throw new UnauthorizedException('Session has been revoked');
        request.user = { ...principal, roles: active.user.memberships.filter(({ schoolId, school }) => schoolId === null || school?.status === 'ACTIVE').map(({ role, schoolId }) => ({ role, schoolId })) };
      } else {
        const active = await this.prisma.studentSession.findFirst({ where: { id: principal.sessionId, studentId: principal.sub, schoolId: principal.schoolId, revokedAt: null, expiresAt: { gt: new Date() }, student: { status: 'ACTIVE', school: { status: 'ACTIVE' } } }, select: { id: true } });
        if (!active) throw new UnauthorizedException('Session has been revoked');
        request.user = principal;
      }
      return true;
    } catch {
      throw new UnauthorizedException('Invalid or expired access token');
    }
  }
}
