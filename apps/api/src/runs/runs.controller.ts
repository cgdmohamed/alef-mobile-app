import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { StaffRole } from '@prisma/client';
import { CurrentUser } from '../common/current-user.decorator';
import { Principal } from '../common/principal';
import { SchoolRoles } from '../common/school-roles.decorator';
import { CreateRunDto, EnrollStudentsDto, ScheduleSessionsDto } from './runs.dto';
import { RunsService } from './runs.service';

@ApiBearerAuth()
@ApiTags('Program Runs')
@SchoolRoles(StaffRole.SCHOOL_ADMIN, StaffRole.TALENT_SPECIALIST)
@Controller('schools/:schoolId/runs')
export class RunsController {
  constructor(private readonly runs: RunsService) {}
  @Post() create(@Param('schoolId') schoolId: string, @Body() dto: CreateRunDto, @CurrentUser() user: Principal) { return this.runs.create(schoolId, dto, user); }
  @Get() list(@Param('schoolId') schoolId: string, @CurrentUser() user: Principal) { return this.runs.list(schoolId, user); }
  @Post(':runId/enrollments') enroll(@Param('schoolId') schoolId: string, @Param('runId') runId: string, @Body() dto: EnrollStudentsDto, @CurrentUser() user: Principal) { return this.runs.enroll(schoolId, runId, dto, user); }
  @Post(':runId/sessions') schedule(@Param('schoolId') schoolId: string, @Param('runId') runId: string, @Body() dto: ScheduleSessionsDto, @CurrentUser() user: Principal) { return this.runs.schedule(schoolId, runId, dto, user); }
}
