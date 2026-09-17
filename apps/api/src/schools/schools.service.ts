import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { Principal } from '../common/principal';
import { TenantAccessService } from '../common/tenant-access.service';
import { PrismaService } from '../database/prisma.service';
import { AuditService } from '../audit/audit.service';
import { CreateClassDto, CreateSchoolDto, UpdateSchoolDto } from './schools.dto';

@Injectable()
export class SchoolsService {
  constructor(private readonly prisma: PrismaService, private readonly access: TenantAccessService, private readonly audit: AuditService) {}

  async create(dto: CreateSchoolDto, principal: Principal) {
    const code = dto.code.trim().toUpperCase();
    if (await this.prisma.school.findUnique({ where: { code } })) throw new ConflictException('School code already exists');
    const school = await this.prisma.school.create({ data: { code, name: dto.name.trim() } });
    await this.audit.write({ actorUserId: principal.sub, action: 'SCHOOL_CREATED', entityType: 'School', entityId: school.id, after: { code, name: school.name } });
    return school;
  }

  list() {
    return this.prisma.school.findMany({ orderBy: { createdAt: 'desc' }, select: { id: true, code: true, name: true, status: true, createdAt: true } });
  }

  async get(id: string, principal: Principal) {
    this.access.assertSchool(principal, id);
    const school = await this.prisma.school.findUnique({ where: { id }, select: { id: true, code: true, name: true, status: true, settings: true, createdAt: true } });
    if (!school) throw new NotFoundException('School not found');
    return school;
  }

  async update(id: string, dto: UpdateSchoolDto, principal: Principal) {
    this.access.assertSchool(principal, id);
    const before = await this.prisma.school.findUnique({ where: { id } });
    if (!before) throw new NotFoundException('School not found');
    const school = await this.prisma.school.update({ where: { id }, data: { name: dto.name?.trim(), status: dto.status } });
    await this.audit.write({ schoolId: id, actorUserId: principal.sub, action: 'SCHOOL_UPDATED', entityType: 'School', entityId: id, before: { name: before.name, status: before.status }, after: { name: school.name, status: school.status } });
    return school;
  }

  async createClass(schoolId: string, dto: CreateClassDto, principal: Principal) {
    this.access.assertSchool(principal, schoolId);
    return this.prisma.schoolClass.create({ data: { schoolId, name: dto.name.trim(), grade: dto.grade.trim(), academicTerm: dto.academicTerm?.trim() } });
  }

  async classes(schoolId: string, principal: Principal) {
    this.access.assertSchool(principal, schoolId);
    return this.prisma.schoolClass.findMany({ where: { schoolId, active: true }, orderBy: [{ grade: 'asc' }, { name: 'asc' }] });
  }
}
