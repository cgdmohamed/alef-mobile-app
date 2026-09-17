import { ForbiddenException } from '@nestjs/common';
import { EntitlementsService } from '../src/common/entitlements.service';
import { PrismaService } from '../src/database/prisma.service';

describe('EntitlementsService', () => {
  const findSubscription = jest.fn();
  const countStudents = jest.fn();
  const countRuns = jest.fn();
  const prisma = {
    subscription: { findFirst: findSubscription },
    student: { count: countStudents },
    programRun: { count: countRuns },
  } as unknown as PrismaService;
  const service = new EntitlementsService(prisma);

  beforeEach(() => jest.clearAllMocks());

  it('requires an active subscription', async () => {
    findSubscription.mockResolvedValue(null);
    await expect(service.limit('school-1', 'max_students')).rejects.toThrow(ForbiddenException);
  });

  it('rejects student creation beyond the plan limit', async () => {
    findSubscription.mockResolvedValue({
      plan: { entitlements: [{ entitlement: { key: 'max_students' }, value: 10 }] },
    });
    countStudents.mockResolvedValue(9);
    await expect(service.assertStudentCapacity('school-1', 2)).rejects.toThrow('Student entitlement limit reached');
  });

  it('excludes the transitioning run from the active-run count', async () => {
    findSubscription.mockResolvedValue({
      plan: { entitlements: [{ entitlement: { key: 'max_active_programs' }, value: 3 }] },
    });
    countRuns.mockResolvedValue(2);
    await expect(service.assertActiveProgramCapacity('school-1', 'run-1')).resolves.toBeUndefined();
    expect(countRuns).toHaveBeenCalledWith({ where: { schoolId: 'school-1', id: { not: 'run-1' }, status: { in: ['SCHEDULED', 'ACTIVE'] } } });
  });
});
