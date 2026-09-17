import { IsEnum, IsOptional, IsString, Length, MinLength } from 'class-validator';
import { SchoolStatus } from '@prisma/client';

export class CreateSchoolDto {
  @IsString()
  @Length(2, 20)
  code!: string;

  @IsString()
  @MinLength(2)
  name!: string;
}

export class UpdateSchoolDto {
  @IsOptional()
  @IsString()
  @MinLength(2)
  name?: string;

  @IsOptional()
  @IsEnum(SchoolStatus)
  status?: SchoolStatus;
}

export class CreateClassDto {
  @IsString()
  @MinLength(1)
  name!: string;

  @IsString()
  @MinLength(1)
  grade!: string;

  @IsOptional()
  @IsString()
  academicTerm?: string;
}
