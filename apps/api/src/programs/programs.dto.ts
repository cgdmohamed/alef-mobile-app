import { ProgramItemType, SubmissionMode } from '@prisma/client';
import { Type } from 'class-transformer';
import { IsArray, IsEnum, IsInt, IsNumber, IsObject, IsOptional, IsString, Min, MinLength, ValidateNested } from 'class-validator';

export class CreateProgramDto {
  @IsString() @MinLength(2) title!: string;
  @IsString() @MinLength(2) slug!: string;
  @IsOptional() @IsString() category?: string;
  @IsOptional() @IsObject() marketing?: Record<string, unknown>;
}

export class CreateVersionDto {
  @IsOptional() @IsString() description?: string;
  @IsOptional() @IsInt() @Min(1) trainingDays?: number;
  @IsOptional() @IsNumber() @Min(0) trainingHours?: number;
  @IsOptional() @IsObject() learningOutcomes?: Record<string, unknown>;
  @IsOptional() @IsObject() assessmentRules?: Record<string, unknown>;
  @IsOptional() @IsObject() recordingPolicy?: Record<string, unknown>;
}

export class CurriculumItemDto {
  @IsEnum(ProgramItemType) type!: ProgramItemType;
  @IsString() @MinLength(1) title!: string;
  @IsOptional() @IsObject() content?: Record<string, unknown>;
  @IsOptional() @IsInt() @Min(0) durationMinutes?: number;
  @IsOptional() @IsEnum(SubmissionMode) submissionMode?: SubmissionMode;
}

export class CurriculumLessonDto {
  @IsString() @MinLength(1) title!: string;
  @IsArray() @ValidateNested({ each: true }) @Type(() => CurriculumItemDto) items!: CurriculumItemDto[];
}

export class CurriculumUnitDto {
  @IsString() @MinLength(1) title!: string;
  @IsArray() @ValidateNested({ each: true }) @Type(() => CurriculumLessonDto) lessons!: CurriculumLessonDto[];
}

export class CurriculumSectionDto {
  @IsString() @MinLength(1) title!: string;
  @IsArray() @ValidateNested({ each: true }) @Type(() => CurriculumUnitDto) units!: CurriculumUnitDto[];
}

export class ReplaceCurriculumDto {
  @IsArray() @ValidateNested({ each: true }) @Type(() => CurriculumSectionDto) sections!: CurriculumSectionDto[];
}
