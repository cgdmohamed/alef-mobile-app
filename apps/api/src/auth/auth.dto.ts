import { IsEmail, IsOptional, IsString, Length, MinLength } from 'class-validator';

export class StaffLoginDto {
  @IsEmail()
  email!: string;

  @IsString()
  @MinLength(8)
  password!: string;
}

export class StudentLoginDto {
  @IsString()
  @Length(2, 20)
  schoolCode!: string;

  @IsString()
  @Length(4, 12)
  accessCode!: string;

  @IsOptional()
  @IsString()
  deviceId?: string;
}

export class RefreshDto {
  @IsString()
  refreshToken!: string;

  @IsString()
  kind!: 'staff' | 'student';
}

export class LogoutDto extends RefreshDto {}
