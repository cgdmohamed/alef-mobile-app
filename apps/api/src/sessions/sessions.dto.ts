import { AttendanceStatus } from '@prisma/client';
import { Type } from 'class-transformer';
import { IsArray, IsEnum, IsInt, IsOptional, IsString, IsUUID, Min, MinLength, ValidateNested } from 'class-validator';
export class AttendanceOverrideDto { @IsUUID() studentId!: string; @IsEnum(AttendanceStatus) status!: AttendanceStatus; @IsInt() @Min(0) connectedSeconds!: number; @IsString() @MinLength(3) reason!: string; }
export class ChatDto { @IsUUID() studentId!: string; @IsString() @MinLength(1) body!: string; }
export class AssessmentDto { @IsUUID() studentId!: string; @IsOptional() @IsUUID() programItemId?: string; @IsOptional() @IsUUID() competencyId?: string; @IsOptional() @IsUUID() scaleLevelId?: string; @IsOptional() @IsString() notes?: string; }
export class ObservationDto { @IsUUID() studentId!: string; @IsString() @MinLength(1) body!: string; }
export class BreakoutRoomDto { @IsString() @MinLength(1) name!: string; @IsArray() @IsUUID('4', { each: true }) studentIds!: string[]; }
export class CreateBreakoutsDto { @IsArray() @ValidateNested({ each: true }) @Type(() => BreakoutRoomDto) rooms!: BreakoutRoomDto[]; }
export class AudioPermissionDto { @IsUUID() studentId!: string; }
export class RecordingProgressDto { @IsInt() @Min(0) watchedSeconds!: number; @IsInt() @Min(0) completionPercent!: number; }
export class SubmitActivityDto { @IsUUID() runId!: string; @IsUUID() programItemId!: string; @IsOptional() @IsUUID() sessionId?: string; @IsOptional() response?: unknown; @IsOptional() @IsUUID() attachmentAssetId?: string; }
export class GradeActivityDto { @IsOptional() @IsString() feedback?: string; }
