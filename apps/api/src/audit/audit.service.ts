import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../database/prisma.service';

@Injectable()
export class AuditService {
  constructor(private readonly prisma: PrismaService) {}

  async write(input: { schoolId?: string; actorUserId?: string; action: string; entityType: string; entityId?: string; before?: Prisma.InputJsonValue; after?: Prisma.InputJsonValue; metadata?: Prisma.InputJsonValue }): Promise<void> {
    await this.prisma.auditLog.create({ data: input });
  }
}
