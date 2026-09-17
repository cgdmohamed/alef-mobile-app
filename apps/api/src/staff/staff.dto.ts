import { StaffRole } from '@prisma/client';
import { IsBoolean, IsEmail, IsEnum, IsOptional, IsString, IsUUID, MinLength } from 'class-validator';

export class CreateStaffDto {
  @IsEmail() email!: string;
  @IsString() @MinLength(2) name!: string;
  @IsString() @MinLength(12) password!: string;
  @IsEnum(StaffRole) role!: StaffRole;
  @IsOptional() @IsUUID() schoolId?: string;
  @IsOptional() @IsBoolean() canTrain?: boolean;
}

export class SchoolStaffDto {
  @IsEmail() email!: string;
  @IsString() @MinLength(2) name!: string;
  @IsString() @MinLength(12) password!: string;
  @IsEnum(StaffRole) role!: StaffRole;
  @IsOptional() @IsBoolean() canTrain?: boolean;
}
