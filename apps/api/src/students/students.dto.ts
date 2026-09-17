import { IsBoolean, IsEmail, IsOptional, IsString, IsUUID, MinLength } from 'class-validator';

export class GuardianDto {
  @IsString()
  @MinLength(2)
  name!: string;

  @IsEmail()
  email!: string;

  @IsString()
  relationship!: string;

  @IsOptional()
  @IsBoolean()
  receiveSessionSummaries?: boolean;

  @IsOptional()
  @IsBoolean()
  receiveFinalReports?: boolean;
}

export class CreateStudentDto {
  @IsString()
  @MinLength(2)
  name!: string;

  @IsString()
  grade!: string;

  @IsOptional()
  @IsUUID()
  classId?: string;

  @IsOptional()
  guardian?: GuardianDto;
}
