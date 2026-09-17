import { ForbiddenException, Injectable } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';

@Injectable()
export class EntitlementsService {
  constructor(private readonly prisma: PrismaService) {}

  async limit(schoolId: string, key: string): Promise<number | null> {
    const subscription = await this.prisma.subscription.findFirst({
      where: { schoolId, status: 'ACTIVE', startsAt: { lte: new Date() }, endsAt: { gte: new Date() } },
      include: { plan: { include: { entitlements: { include: { entitlement: true } } } } },
      orderBy: { endsAt: 'desc' },
    });
    if (!subscription) throw new ForbiddenException('An active subscription is required');
    const value = subscription.plan.entitlements.find((item) => item.entitlement.key === key)?.value;
    return typeof value === 'number' && Number.isFinite(value) ? value : null;
  }

  async assertStudentCapacity(schoolId: string, additional: number): Promise<void> {
    const limit = await this.limit(schoolId, 'max_students');
    if (limit === null) return;
    const active = await this.prisma.student.count({ where: { schoolId, status: 'ACTIVE' } });
    if (active + additional > limit) throw new ForbiddenException('Student entitlement limit reached');
  }

  async assertActiveProgramCapacity(schoolId: string, excludeRunId?: string): Promise<void> {
    const limit = await this.limit(schoolId, 'max_active_programs');
    if (limit === null) return;
    const active = await this.prisma.programRun.count({ where: { schoolId, ...(excludeRunId ? { id: { not: excludeRunId } } : {}), status: { in: ['SCHEDULED', 'ACTIVE'] } } });
    if (active >= limit) throw new ForbiddenException('Active program entitlement limit reached');
  }
}
