import { Body, Controller, Get, Param, Post, Query } from '@nestjs/common'; import { ApiBearerAuth, ApiTags } from '@nestjs/swagger'; import { StaffRole } from '@prisma/client';
import { CurrentUser } from '../common/current-user.decorator'; import { Principal } from '../common/principal'; import { Public } from '../common/public.decorator'; import { Roles } from '../common/roles.decorator'; import { SchoolRoles } from '../common/school-roles.decorator'; import { BlogDto, CmsPageDto, CreateMediaDto, DeviceTokenDto, DispatchNotificationDto, ReportRequestDto, TemplateDto } from './platform.dto'; import { PlatformService } from './platform.service';
@ApiBearerAuth() @ApiTags('Platform') @Controller() export class PlatformController { constructor(private readonly service: PlatformService) {}
  @SchoolRoles(StaffRole.SCHOOL_ADMIN, StaffRole.TALENT_SPECIALIST) @Post('schools/:schoolId/media') media(@Param('schoolId') id: string, @Body() dto: CreateMediaDto, @CurrentUser() user: Principal) { return this.service.media(id, dto, user); }
  @Roles(StaffRole.ALIF_SUPER_ADMIN) @Post('cms/pages') page(@Body() dto: CmsPageDto) { return this.service.page(dto); }
  @Roles(StaffRole.ALIF_SUPER_ADMIN) @Post('cms/blog') blog(@Body() dto: BlogDto, @CurrentUser() user: Principal) { return this.service.blog(dto, user); }
  @Public() @Get('public/pages/:slug') publicPage(@Param('slug') slug: string) { return this.service.publicPage(slug); }
  @Public() @Get('public/blog') posts() { return this.service.publicPosts(); }
  @Public() @Get('public/blog/:slug') post(@Param('slug') slug: string) { return this.service.publicPost(slug); }
  @Roles(StaffRole.ALIF_SUPER_ADMIN) @Post('templates') template(@Body() dto: TemplateDto) { return this.service.template(dto); }
  @Roles(StaffRole.ALIF_SUPER_ADMIN) @Post('notifications/dispatch') dispatch(@Body() dto: DispatchNotificationDto) { return this.service.dispatch(dto); }
  @Post('notifications/devices') device(@Body() dto: DeviceTokenDto, @CurrentUser() user: Principal) { return this.service.device(dto, user); }
  @Get('notifications') notifications(@CurrentUser() user: Principal) { return this.service.notifications(user); }
  @Post('notifications/:id/read') read(@Param('id') id: string, @CurrentUser() user: Principal) { return this.service.readNotification(id, user); }
  @SchoolRoles(StaffRole.SCHOOL_ADMIN, StaffRole.TALENT_SPECIALIST) @Post('schools/:schoolId/reports') report(@Param('schoolId') id: string, @Body() dto: ReportRequestDto, @CurrentUser() user: Principal) { return this.service.report(id, dto, user); }
  @SchoolRoles(StaffRole.SCHOOL_ADMIN, StaffRole.TALENT_SPECIALIST) @Get('schools/:schoolId/reports') reports(@Param('schoolId') id: string, @CurrentUser() user: Principal) { return this.service.reports(id, user); }
  @SchoolRoles(StaffRole.SCHOOL_ADMIN, StaffRole.TALENT_SPECIALIST) @Get('schools/:schoolId/reports/:reportId/download') reportDownload(@Param('schoolId') id: string, @Param('reportId') reportId: string, @CurrentUser() user: Principal) { return this.service.reportDownload(id, reportId, user); }
  @SchoolRoles(StaffRole.SCHOOL_ADMIN, StaffRole.TALENT_SPECIALIST) @Get('schools/:schoolId/run-reports/:runId') runReport(@Param('schoolId') id: string, @Param('runId') runId: string, @CurrentUser() user: Principal) { return this.service.runReport(id, runId, user); }
  @Roles(StaffRole.ALIF_SUPER_ADMIN) @Get('reports/platform') platformReport(@CurrentUser() user: Principal) { return this.service.platformReport(user); }
  @Get('audit') audit(@Query('schoolId') schoolId: string | undefined, @Query('action') action: string | undefined, @CurrentUser() user: Principal) { return this.service.audit(schoolId, user, action); }
  @Roles(StaffRole.ALIF_SUPER_ADMIN) @Get('operations/jobs') jobs(@CurrentUser() user: Principal) { return this.service.jobs(user); }
}
