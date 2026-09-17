import { Body, Controller, Delete, Get, Param, Post } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { StaffRole } from '@prisma/client';
import { CurrentUser } from '../common/current-user.decorator'; import { Principal } from '../common/principal'; import { Roles } from '../common/roles.decorator'; import { SchoolRoles } from '../common/school-roles.decorator'; import { CreateStaffDto, SchoolStaffDto } from './staff.dto'; import { StaffService } from './staff.service';
@ApiBearerAuth() @ApiTags('Staff') @Controller() export class StaffController { constructor(private readonly service: StaffService) {}
  @Roles(StaffRole.ALIF_SUPER_ADMIN) @Post('staff') create(@Body() dto: CreateStaffDto, @CurrentUser() user: Principal) { return this.service.createGlobal(dto, user); }
  @Roles(StaffRole.ALIF_SUPER_ADMIN) @Post('staff/:userId/disable') disable(@Param('userId') id: string, @CurrentUser() user: Principal) { return this.service.disable(id, user); }
  @SchoolRoles(StaffRole.SCHOOL_ADMIN) @Post('schools/:schoolId/staff') createSchool(@Param('schoolId') id: string, @Body() dto: SchoolStaffDto, @CurrentUser() user: Principal) { return this.service.createSchool(id, dto, user); }
  @SchoolRoles(StaffRole.SCHOOL_ADMIN) @Get('schools/:schoolId/staff') list(@Param('schoolId') id: string, @CurrentUser() user: Principal) { return this.service.list(id, user); }
  @SchoolRoles(StaffRole.SCHOOL_ADMIN) @Delete('schools/:schoolId/staff/:membershipId') revoke(@Param('schoolId') id: string, @Param('membershipId') membershipId: string, @CurrentUser() user: Principal) { return this.service.revoke(id, membershipId, user); }
}
