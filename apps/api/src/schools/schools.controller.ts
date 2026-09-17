import { Body, Controller, Get, Param, Patch, Post } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { StaffRole } from '@prisma/client';
import { CurrentUser } from '../common/current-user.decorator';
import { Principal } from '../common/principal';
import { Roles } from '../common/roles.decorator';
import { SchoolRoles } from '../common/school-roles.decorator';
import { CreateClassDto, CreateSchoolDto, UpdateSchoolDto } from './schools.dto';
import { SchoolsService } from './schools.service';

@ApiBearerAuth()
@ApiTags('Schools')
@Controller('schools')
export class SchoolsController {
  constructor(private readonly schools: SchoolsService) {}

  @Roles(StaffRole.ALIF_SUPER_ADMIN)
  @Post()
  create(@Body() dto: CreateSchoolDto, @CurrentUser() user: Principal) { return this.schools.create(dto, user); }

  @Roles(StaffRole.ALIF_SUPER_ADMIN)
  @Get()
  list() { return this.schools.list(); }

  @SchoolRoles(StaffRole.SCHOOL_ADMIN, StaffRole.TALENT_SPECIALIST)
  @Get(':schoolId')
  get(@Param('schoolId') id: string, @CurrentUser() user: Principal) { return this.schools.get(id, user); }

  @SchoolRoles(StaffRole.SCHOOL_ADMIN)
  @Patch(':schoolId')
  update(@Param('schoolId') id: string, @Body() dto: UpdateSchoolDto, @CurrentUser() user: Principal) { return this.schools.update(id, dto, user); }

  @SchoolRoles(StaffRole.SCHOOL_ADMIN, StaffRole.TALENT_SPECIALIST)
  @Post(':schoolId/classes')
  createClass(@Param('schoolId') id: string, @Body() dto: CreateClassDto, @CurrentUser() user: Principal) { return this.schools.createClass(id, dto, user); }

  @SchoolRoles(StaffRole.SCHOOL_ADMIN, StaffRole.TALENT_SPECIALIST)
  @Get(':schoolId/classes')
  classes(@Param('schoolId') id: string, @CurrentUser() user: Principal) { return this.schools.classes(id, user); }
}
