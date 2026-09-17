import { Body, Controller, Get, Param, Post, Put } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { StaffRole } from '@prisma/client';
import { CurrentUser } from '../common/current-user.decorator';
import { Principal } from '../common/principal';
import { Public } from '../common/public.decorator';
import { Roles } from '../common/roles.decorator';
import { CreateProgramDto, CreateVersionDto, ReplaceCurriculumDto } from './programs.dto';
import { ProgramsService } from './programs.service';

@ApiTags('Programs')
@Controller('programs')
export class ProgramsController {
  constructor(private readonly programs: ProgramsService) {}

  @Public() @Get() list() { return this.programs.listPublished(); }
  @Public() @Get('by-slug/:slug') get(@Param('slug') slug: string) { return this.programs.getBySlug(slug); }

  @ApiBearerAuth() @Roles(StaffRole.ALIF_SUPER_ADMIN, StaffRole.PROGRAM_MANAGER)
  @Post() create(@Body() dto: CreateProgramDto, @CurrentUser() user: Principal) { return this.programs.create(dto, user); }

  @ApiBearerAuth() @Roles(StaffRole.ALIF_SUPER_ADMIN, StaffRole.PROGRAM_MANAGER)
  @Post(':programId/versions') createVersion(@Param('programId') id: string, @Body() dto: CreateVersionDto, @CurrentUser() user: Principal) { return this.programs.createVersion(id, dto, user); }

  @ApiBearerAuth() @Roles(StaffRole.ALIF_SUPER_ADMIN, StaffRole.PROGRAM_MANAGER)
  @Put('versions/:versionId/curriculum') curriculum(@Param('versionId') id: string, @Body() dto: ReplaceCurriculumDto, @CurrentUser() user: Principal) { return this.programs.replaceCurriculum(id, dto, user); }

  @ApiBearerAuth() @Roles(StaffRole.ALIF_SUPER_ADMIN, StaffRole.PROGRAM_MANAGER)
  @Post('versions/:versionId/publish') publish(@Param('versionId') id: string, @CurrentUser() user: Principal) { return this.programs.publish(id, user); }
}
