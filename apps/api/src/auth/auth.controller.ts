import { Body, Controller, Get, Headers, Ip, Post } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { CurrentUser } from '../common/current-user.decorator';
import { Principal } from '../common/principal';
import { Public } from '../common/public.decorator';
import { LogoutDto, RefreshDto, StaffLoginDto, StudentLoginDto } from './auth.dto';
import { AuthService } from './auth.service';

@ApiTags('Authentication')
@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Public()
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  @Post('staff/login')
  staffLogin(@Body() dto: StaffLoginDto, @Ip() ip: string, @Headers('user-agent') userAgent?: string) {
    return this.auth.staffLogin(dto, ip, userAgent);
  }

  @Public()
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  @Post('student/login')
  studentLogin(@Body() dto: StudentLoginDto) {
    return this.auth.studentLogin(dto);
  }

  @Public()
  @Throttle({ default: { limit: 15, ttl: 60_000 } })
  @Post('refresh')
  refresh(@Body() dto: RefreshDto) {
    return this.auth.refresh(dto.kind, dto.refreshToken);
  }

  @Public()
  @Post('logout')
  async logout(@Body() dto: LogoutDto) {
    await this.auth.logout(dto.kind, dto.refreshToken);
    return { success: true };
  }

  @ApiBearerAuth()
  @Get('me')
  me(@CurrentUser() principal: Principal) {
    return this.auth.me(principal);
  }
}
