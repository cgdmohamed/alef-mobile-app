import { BillingPeriod, InvoiceStatus } from '@prisma/client';
import { IsArray, IsDateString, IsEnum, IsIn, IsNumber, IsOptional, IsString, IsUUID, Min, MinLength } from 'class-validator';

export class CreatePlanDto { @IsString() @MinLength(2) name!: string; @IsArray() entitlements!: Array<{ key: string; value: unknown }>; }
export class CreateSubscriptionDto { @IsUUID() planId!: string; @IsEnum(BillingPeriod) period!: BillingPeriod; @IsDateString() startsAt!: string; @IsDateString() endsAt!: string; }
export class CreateInvoiceDto { @IsString() number!: string; @IsNumber() @Min(0) total!: number; @IsOptional() @IsDateString() dueAt?: string; @IsOptional() @IsUUID() subscriptionId?: string; }
export class IssueInvoiceDto { @IsIn([InvoiceStatus.ISSUED, InvoiceStatus.CANCELLED]) status!: InvoiceStatus; }
export class RecordPaymentDto { @IsNumber() @Min(0.01) amount!: number; @IsDateString() paidAt!: string; @IsString() method!: string; @IsOptional() @IsString() reference?: string; @IsOptional() @IsString() notes?: string; }
