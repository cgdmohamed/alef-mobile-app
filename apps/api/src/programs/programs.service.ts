import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { Prisma, ProgramVersionStatus } from '@prisma/client';
import { AuditService } from '../audit/audit.service';
import { Principal } from '../common/principal';
import { PrismaService } from '../database/prisma.service';
import { CreateProgramDto, CreateVersionDto, ReplaceCurriculumDto } from './programs.dto';

@Injectable()
export class ProgramsService {
  constructor(private readonly prisma: PrismaService, private readonly audit: AuditService) {}

  async create(dto: CreateProgramDto, principal: Principal) {
    const slug = dto.slug.trim().toLowerCase();
    if (await this.prisma.program.findUnique({ where: { slug } })) throw new ConflictException('Program slug already exists');
    const program = await this.prisma.program.create({ data: { title: dto.title.trim(), slug, category: dto.category?.trim(), marketing: dto.marketing as Prisma.InputJsonValue | undefined } });
    await this.audit.write({ actorUserId: principal.sub, action: 'PROGRAM_CREATED', entityType: 'Program', entityId: program.id });
    return program;
  }

  listPublished() {
    return this.prisma.program.findMany({ where: { versions: { some: { status: ProgramVersionStatus.PUBLISHED } } }, select: { id: true, title: true, slug: true, category: true, coverKey: true, targetGrades: true, targetAges: true, marketing: true, versions: { where: { status: ProgramVersionStatus.PUBLISHED }, orderBy: { version: 'desc' }, take: 1, select: { id: true, version: true, trainingDays: true, trainingHours: true, learningOutcomes: true } } }, orderBy: { title: 'asc' } });
  }

  async getBySlug(slug: string) {
    const program = await this.prisma.program.findUnique({ where: { slug }, select: { id: true, title: true, slug: true, category: true, coverKey: true, targetGrades: true, targetAges: true, marketing: true, versions: { where: { status: ProgramVersionStatus.PUBLISHED }, orderBy: { version: 'desc' }, take: 1, select: { id: true, version: true, description: true, trainingDays: true, trainingHours: true, learningOutcomes: true } } } });
    if (!program || !program.versions.length) throw new NotFoundException('Program not found');
    return program;
  }

  async createVersion(programId: string, dto: CreateVersionDto, principal: Principal) {
    const program = await this.prisma.program.findUnique({ where: { id: programId }, include: { versions: { orderBy: { version: 'desc' }, take: 1 } } });
    if (!program) throw new NotFoundException('Program not found');
    const version = await this.prisma.programVersion.create({ data: { programId, version: (program.versions[0]?.version ?? 0) + 1, description: dto.description, trainingDays: dto.trainingDays, trainingHours: dto.trainingHours, learningOutcomes: dto.learningOutcomes as Prisma.InputJsonValue | undefined, assessmentRules: dto.assessmentRules as Prisma.InputJsonValue | undefined, recordingPolicy: dto.recordingPolicy as Prisma.InputJsonValue | undefined } });
    await this.audit.write({ actorUserId: principal.sub, action: 'PROGRAM_VERSION_CREATED', entityType: 'ProgramVersion', entityId: version.id });
    return version;
  }

  async replaceCurriculum(versionId: string, dto: ReplaceCurriculumDto, principal: Principal) {
    const version = await this.prisma.programVersion.findUnique({ where: { id: versionId } });
    if (!version) throw new NotFoundException('Program version not found');
    if (version.status !== ProgramVersionStatus.DRAFT) throw new ConflictException('Published program versions are immutable');
    await this.prisma.$transaction(async (tx) => {
      await tx.programSection.deleteMany({ where: { programVersionId: versionId } });
      for (const [sectionPosition, section] of dto.sections.entries()) {
        await tx.programSection.create({ data: { programVersionId: versionId, title: section.title, position: sectionPosition, units: { create: section.units.map((unit, unitPosition) => ({ title: unit.title, position: unitPosition, lessons: { create: unit.lessons.map((lesson, lessonPosition) => ({ title: lesson.title, position: lessonPosition, items: { create: lesson.items.map((item, itemPosition) => ({ type: item.type, title: item.title, content: item.content as Prisma.InputJsonValue | undefined, durationMinutes: item.durationMinutes, submissionMode: item.submissionMode, position: itemPosition })) } })) } })) } } });
      }
    });
    await this.audit.write({ actorUserId: principal.sub, action: 'PROGRAM_CURRICULUM_REPLACED', entityType: 'ProgramVersion', entityId: versionId });
    return this.getVersion(versionId);
  }

  async publish(versionId: string, principal: Principal) {
    const version = await this.prisma.programVersion.findUnique({ where: { id: versionId }, include: { sections: { include: { units: { include: { lessons: { include: { items: true } } } } } } } });
    if (!version) throw new NotFoundException('Program version not found');
    if (!version.sections.length || !version.sections.some((section) => section.units.some((unit) => unit.lessons.some((lesson) => lesson.items.length)))) throw new ConflictException('Cannot publish an empty curriculum');
    if (version.status !== ProgramVersionStatus.DRAFT) throw new ConflictException('Only draft versions can be published');
    const published = await this.prisma.programVersion.update({ where: { id: versionId }, data: { status: ProgramVersionStatus.PUBLISHED, publishedAt: new Date() } });
    await this.audit.write({ actorUserId: principal.sub, action: 'PROGRAM_VERSION_PUBLISHED', entityType: 'ProgramVersion', entityId: versionId });
    return published;
  }

  getVersion(versionId: string) {
    return this.prisma.programVersion.findUniqueOrThrow({ where: { id: versionId }, include: { sections: { orderBy: { position: 'asc' }, include: { units: { orderBy: { position: 'asc' }, include: { lessons: { orderBy: { position: 'asc' }, include: { items: { orderBy: { position: 'asc' } } } } } } } } } });
  }
}
