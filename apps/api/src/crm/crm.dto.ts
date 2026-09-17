import { LeadActivityType, LeadStatus } from '@prisma/client';
import { IsEmail, IsEnum, IsInt, IsOptional, IsString, Min, MinLength } from 'class-validator';
export class CreateLeadDto { @IsString() @MinLength(2) schoolName!: string; @IsString() @MinLength(2) contactName!: string; @IsEmail() email!: string; @IsOptional() @IsString() phone?: string; @IsOptional() @IsInt() @Min(0) approximateStudents?: number; @IsOptional() @IsInt() @Min(0) approximateClasses?: number; @IsOptional() @IsString() message?: string; }
export class LeadStatusDto { @IsEnum(LeadStatus) status!: LeadStatus; }
export class LeadActivityDto { @IsEnum(LeadActivityType) type!: LeadActivityType; @IsString() @MinLength(1) body!: string; }
