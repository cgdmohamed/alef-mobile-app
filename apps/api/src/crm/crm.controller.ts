import { Body, Controller, Get, Param, Patch, Post } from '@nestjs/common'; import { ApiBearerAuth, ApiTags } from '@nestjs/swagger'; import { StaffRole } from '@prisma/client';
import { CurrentUser } from '../common/current-user.decorator'; import { Principal } from '../common/principal'; import { Public } from '../common/public.decorator'; import { Roles } from '../common/roles.decorator'; import { CreateLeadDto, LeadActivityDto, LeadStatusDto } from './crm.dto'; import { CrmService } from './crm.service';
@ApiTags('CRM') @Controller('crm/leads') export class CrmController { constructor(private readonly crm: CrmService) {}
  @Public() @Post('public') create(@Body() dto: CreateLeadDto) { return this.crm.create(dto); }
  @ApiBearerAuth() @Roles(StaffRole.ALIF_SUPER_ADMIN) @Get() list() { return this.crm.list(); }
  @ApiBearerAuth() @Roles(StaffRole.ALIF_SUPER_ADMIN) @Patch(':id/status') status(@Param('id') id: string, @Body() dto: LeadStatusDto, @CurrentUser() user: Principal) { return this.crm.status(id, dto, user); }
  @ApiBearerAuth() @Roles(StaffRole.ALIF_SUPER_ADMIN) @Post(':id/activities') activity(@Param('id') id: string, @Body() dto: LeadActivityDto) { return this.crm.activity(id, dto); }
  @ApiBearerAuth() @Roles(StaffRole.ALIF_SUPER_ADMIN) @Post(':id/convert') convert(@Param('id') id: string, @CurrentUser() user: Principal) { return this.crm.convert(id, user); }
}
