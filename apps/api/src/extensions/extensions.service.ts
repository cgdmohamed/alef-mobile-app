import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { ExtensionScope, PlacementType, Prisma, ProgramItemType } from '@prisma/client';
import { Principal } from '../common/principal'; import { TenantAccessService } from '../common/tenant-access.service'; import { PrismaService } from '../database/prisma.service'; import { CreateExtensionDto } from './extensions.dto';
@Injectable() export class ExtensionsService {
  constructor(private readonly prisma: PrismaService, private readonly access: TenantAccessService) {}
  async create(schoolId: string, dto: CreateExtensionDto, actor: Principal) {
    this.access.assertSchool(actor, schoolId);
    if (dto.itemType !== ProgramItemType.ACTIVITY && dto.itemType !== ProgramItemType.QUESTION && dto.itemType !== ProgramItemType.RESOURCE) throw new BadRequestException('Schools may add only activities, questions, or resources');
    if (dto.scope === ExtensionScope.PROGRAM_RUN && !dto.runId) throw new BadRequestException('Run scope requires runId');
    if (dto.scope === ExtensionScope.SCHOOL && dto.runId) throw new BadRequestException('School scope cannot specify runId');
    if (dto.placement === PlacementType.END_OF_UNIT && !dto.unitId) throw new BadRequestException('End-of-unit placement requires unitId');
    if (dto.placement !== PlacementType.END_OF_UNIT && !dto.anchorItemId) throw new BadRequestException('Item placement requires anchorItemId');
    const version = await this.prisma.programVersion.findUnique({ where: { id: dto.programVersionId } }); if (!version) throw new NotFoundException('Program version not found');
    if (dto.runId && !(await this.prisma.programRun.findFirst({ where: { id: dto.runId, schoolId, programVersionId: dto.programVersionId } }))) throw new NotFoundException('Program run not found');
    if (dto.unitId && !(await this.prisma.programUnit.findFirst({ where: { id: dto.unitId, section: { programVersionId: dto.programVersionId } } }))) throw new NotFoundException('Unit not found in program version');
    if (dto.anchorItemId && !(await this.prisma.programItem.findFirst({ where: { id: dto.anchorItemId, lesson: { unit: { section: { programVersionId: dto.programVersionId } } } } }))) throw new NotFoundException('Anchor item not found in program version');
    return this.prisma.$transaction(async (tx) => { const extension = await tx.programExtension.create({ data: { schoolId, programVersionId: dto.programVersionId, runId: dto.runId, unitId: dto.unitId, anchorItemId: dto.anchorItemId, scope: dto.scope, placement: dto.placement, itemType: dto.itemType, title: dto.title, content: dto.content as Prisma.InputJsonValue | undefined, createdById: actor.sub } }); await tx.auditLog.create({ data: { schoolId, actorUserId: actor.sub, action: 'PROGRAM_EXTENSION_CREATED', entityType: 'ProgramExtension', entityId: extension.id } }); return extension; });
  }
  async list(schoolId: string, versionId: string, actor: Principal, runId?: string) { this.access.assertSchool(actor, schoolId); return this.prisma.programExtension.findMany({ where: { schoolId, programVersionId: versionId, OR: [{ scope: ExtensionScope.SCHOOL }, ...(runId ? [{ scope: ExtensionScope.PROGRAM_RUN, runId }] : [])] }, orderBy: { createdAt: 'asc' } }); }
}
