import { Body, Controller, Get, Param, Patch, Post } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { StaffRole } from '@prisma/client';
import { CurrentUser } from '../common/current-user.decorator'; import { Principal } from '../common/principal'; import { Roles } from '../common/roles.decorator'; import { SchoolRoles } from '../common/school-roles.decorator';
import { CommercialService } from './commercial.service'; import { CreateInvoiceDto, CreatePlanDto, CreateSubscriptionDto, IssueInvoiceDto, RecordPaymentDto } from './commercial.dto';

@ApiBearerAuth() @ApiTags('Commercial') @Controller('commercial')
export class CommercialController {
  constructor(private readonly service: CommercialService) {}
  @Roles(StaffRole.ALIF_SUPER_ADMIN) @Post('plans') createPlan(@Body() dto: CreatePlanDto, @CurrentUser() user: Principal) { return this.service.createPlan(dto, user); }
  @Roles(StaffRole.ALIF_SUPER_ADMIN) @Get('plans') plans() { return this.service.plans(); }
  @Roles(StaffRole.ALIF_SUPER_ADMIN) @Post('schools/:schoolId/subscriptions') subscribe(@Param('schoolId') schoolId: string, @Body() dto: CreateSubscriptionDto, @CurrentUser() user: Principal) { return this.service.subscribe(schoolId, dto, user); }
  @Roles(StaffRole.ALIF_SUPER_ADMIN) @Post('schools/:schoolId/invoices') invoice(@Param('schoolId') schoolId: string, @Body() dto: CreateInvoiceDto, @CurrentUser() user: Principal) { return this.service.createInvoice(schoolId, dto, user); }
  @Roles(StaffRole.ALIF_SUPER_ADMIN) @Patch('schools/:schoolId/invoices/:invoiceId/status') issue(@Param('schoolId') schoolId: string, @Param('invoiceId') invoiceId: string, @Body() dto: IssueInvoiceDto, @CurrentUser() user: Principal) { return this.service.issue(schoolId, invoiceId, dto, user); }
  @Roles(StaffRole.ALIF_SUPER_ADMIN) @Post('schools/:schoolId/invoices/:invoiceId/payments') payment(@Param('schoolId') schoolId: string, @Param('invoiceId') invoiceId: string, @Body() dto: RecordPaymentDto, @CurrentUser() user: Principal) { return this.service.payment(schoolId, invoiceId, dto, user); }
  @SchoolRoles(StaffRole.SCHOOL_ADMIN) @Get('schools/:schoolId/invoices') invoices(@Param('schoolId') schoolId: string, @CurrentUser() user: Principal) { return this.service.invoices(schoolId, user); }
}
