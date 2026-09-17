import { Type } from 'class-transformer';
import { IsArray, IsDateString, IsEnum, IsInt, IsOptional, IsString, IsUUID, Min, MinLength, ValidateNested } from 'class-validator';
import { RunStatus } from '@prisma/client';

export class CreateRunDto {
  @IsUUID() programVersionId!: string;
  @IsString() @MinLength(1) name!: string;
  @IsOptional() @IsString() academicTerm?: string;
  @IsOptional() @IsUUID() trainerMembershipId?: string;
  @IsOptional() @IsUUID() specialistMembershipId?: string;
  @IsDateString() startsAt!: string;
  @IsDateString() endsAt!: string;
  @IsOptional() @IsInt() @Min(1) recordingRetentionDays?: number;
}

export class EnrollStudentsDto {
  @IsArray() @IsUUID('4', { each: true }) studentIds!: string[];
}

export class SessionDto {
  @IsString() @MinLength(1) title!: string;
  @IsDateString() scheduledStart!: string;
  @IsDateString() scheduledEnd!: string;
}

export class ScheduleSessionsDto {
  @IsArray() @ValidateNested({ each: true }) @Type(() => SessionDto) sessions!: SessionDto[];
}
export class RunStatusDto { @IsEnum(RunStatus) status!: RunStatus; }
