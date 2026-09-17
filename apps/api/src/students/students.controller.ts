import { Body, Controller, Get, Param, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { StaffRole } from '@prisma/client';
import { CurrentUser } from '../common/current-user.decorator';
import { Principal } from '../common/principal';
import { Roles } from '../common/roles.decorator';
import { CreateStudentDto } from './students.dto';
import { StudentsService } from './students.service';

@ApiBearerAuth()
@ApiTags('Students')
@Controller('schools/:schoolId/students')
export class StudentsController {
  constructor(private readonly students: StudentsService) {}

  @Roles(StaffRole.ALIF_SUPER_ADMIN, StaffRole.SCHOOL_ADMIN, StaffRole.TALENT_SPECIALIST)
  @Post()
  create(@Param('schoolId') schoolId: string, @Body() dto: CreateStudentDto, @CurrentUser() user: Principal) { return this.students.create(schoolId, dto, user); }

  @Roles(StaffRole.ALIF_SUPER_ADMIN, StaffRole.SCHOOL_ADMIN, StaffRole.TALENT_SPECIALIST, StaffRole.ALIF_TRAINER)
  @Get()
  list(@Param('schoolId') schoolId: string, @CurrentUser() user: Principal, @Query('cursor') cursor?: string) { return this.students.list(schoolId, user, cursor); }

  @Roles(StaffRole.ALIF_SUPER_ADMIN, StaffRole.SCHOOL_ADMIN, StaffRole.TALENT_SPECIALIST, StaffRole.ALIF_TRAINER)
  @Get(':studentId')
  get(@Param('schoolId') schoolId: string, @Param('studentId') studentId: string, @CurrentUser() user: Principal) { return this.students.get(schoolId, studentId, user); }

  @Roles(StaffRole.ALIF_SUPER_ADMIN, StaffRole.SCHOOL_ADMIN, StaffRole.TALENT_SPECIALIST)
  @Post(':studentId/regenerate-access-code')
  regenerate(@Param('schoolId') schoolId: string, @Param('studentId') studentId: string, @CurrentUser() user: Principal) { return this.students.regenerateCode(schoolId, studentId, user); }

  @Roles(StaffRole.ALIF_SUPER_ADMIN, StaffRole.SCHOOL_ADMIN)
  @Post(':studentId/disable')
  disable(@Param('schoolId') schoolId: string, @Param('studentId') studentId: string, @CurrentUser() user: Principal) { return this.students.disable(schoolId, studentId, user); }
}
