import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InvoiceStatus, Prisma, SubscriptionStatus } from '@prisma/client';
import { Principal } from '../common/principal';
import { TenantAccessService } from '../common/tenant-access.service';
import { PrismaService } from '../database/prisma.service';
import { CreateInvoiceDto, CreatePlanDto, CreateSubscriptionDto, IssueInvoiceDto, RecordPaymentDto } from './commercial.dto';

@Injectable()
export class CommercialService {
  constructor(private readonly prisma: PrismaService, private readonly access: TenantAccessService) {}
  async createPlan(dto: CreatePlanDto, actor: Principal) {
    return this.prisma.$transaction(async (tx) => {
      const plan = await tx.plan.create({ data: { name: dto.name } });
      for (const item of dto.entitlements) {
        const entitlement = await tx.entitlement.upsert({ where: { key: item.key }, create: { key: item.key }, update: {} });
        await tx.planEntitlement.create({ data: { planId: plan.id, entitlementId: entitlement.id, value: item.value as Prisma.InputJsonValue } });
      }
      await tx.auditLog.create({ data: { actorUserId: actor.sub, action: 'PLAN_CREATED', entityType: 'Plan', entityId: plan.id } });
      return plan;
    });
  }
  plans() { return this.prisma.plan.findMany({ where: { active: true }, include: { entitlements: { include: { entitlement: true } } } }); }
  async subscribe(schoolId: string, dto: CreateSubscriptionDto, actor: Principal) {
    this.access.assertSchool(actor, schoolId);
    const startsAt = new Date(dto.startsAt); const endsAt = new Date(dto.endsAt);
    if (startsAt >= endsAt) throw new BadRequestException('Subscription end must be after start');
    return this.prisma.$transaction(async (tx) => {
      const subscription = await tx.subscription.create({ data: { schoolId, planId: dto.planId, period: dto.period, startsAt, endsAt, status: SubscriptionStatus.ACTIVE } });
      await tx.auditLog.create({ data: { schoolId, actorUserId: actor.sub, action: 'SUBSCRIPTION_CREATED', entityType: 'Subscription', entityId: subscription.id } });
      return subscription;
    });
  }
  async createInvoice(schoolId: string, dto: CreateInvoiceDto, actor: Principal) {
    this.access.assertSchool(actor, schoolId);
    return this.prisma.$transaction(async (tx) => {
      if (dto.subscriptionId && !(await tx.subscription.findFirst({ where: { id: dto.subscriptionId, schoolId } }))) throw new NotFoundException('Subscription not found');
      const invoice = await tx.invoice.create({ data: { schoolId, subscriptionId: dto.subscriptionId, number: dto.number, total: dto.total, dueAt: dto.dueAt ? new Date(dto.dueAt) : undefined } });
      await tx.auditLog.create({ data: { schoolId, actorUserId: actor.sub, action: 'INVOICE_CREATED', entityType: 'Invoice', entityId: invoice.id } });
      return invoice;
    });
  }
  async issue(schoolId: string, invoiceId: string, dto: IssueInvoiceDto, actor: Principal) {
    this.access.assertSchool(actor, schoolId);
    const invoice = await this.prisma.invoice.findFirst({ where: { id: invoiceId, schoolId } });
    if (!invoice) throw new NotFoundException('Invoice not found');
    if (invoice.status !== InvoiceStatus.DRAFT && dto.status === InvoiceStatus.ISSUED) throw new BadRequestException('Only draft invoices can be issued');
    return this.prisma.invoice.update({ where: { id: invoiceId }, data: { status: dto.status, issuedAt: dto.status === InvoiceStatus.ISSUED ? new Date() : invoice.issuedAt } });
  }
  async payment(schoolId: string, invoiceId: string, dto: RecordPaymentDto, actor: Principal) {
    this.access.assertSchool(actor, schoolId);
    return this.prisma.$transaction(async (tx) => {
      const invoice = await tx.invoice.findFirst({ where: { id: invoiceId, schoolId }, include: { payments: true } });
      if (!invoice || invoice.status === InvoiceStatus.DRAFT || invoice.status === InvoiceStatus.CANCELLED) throw new BadRequestException('Invoice cannot receive payments');
      const paid = invoice.payments.reduce((sum, item) => sum.plus(item.amount), new Prisma.Decimal(dto.amount));
      if (paid.greaterThan(invoice.total)) throw new BadRequestException('Payment exceeds outstanding balance');
      const payment = await tx.payment.create({ data: { schoolId, invoiceId, amount: dto.amount, paidAt: new Date(dto.paidAt), method: dto.method, reference: dto.reference, notes: dto.notes } });
      await tx.invoice.update({ where: { id: invoiceId }, data: { status: paid.equals(invoice.total) ? InvoiceStatus.PAID : InvoiceStatus.PARTIALLY_PAID } });
      await tx.auditLog.create({ data: { schoolId, actorUserId: actor.sub, action: 'PAYMENT_RECORDED', entityType: 'Payment', entityId: payment.id } });
      return payment;
    });
  }
  async invoices(schoolId: string, actor: Principal) { this.access.assertSchool(actor, schoolId); return this.prisma.invoice.findMany({ where: { schoolId }, include: { payments: true }, orderBy: { issuedAt: 'desc' } }); }
}
