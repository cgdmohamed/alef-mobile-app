import { Body, Controller, Get, Param, Post, Query } from '@nestjs/common'; import { ApiBearerAuth, ApiTags } from '@nestjs/swagger'; import { BreakoutStatus, SessionStatus } from '@prisma/client';
import { CurrentUser } from '../common/current-user.decorator'; import { Principal } from '../common/principal'; import { AssessmentDto, AttendanceOverrideDto, AudioPermissionDto, ChatDto, CreateBreakoutsDto, GradeActivityDto, ObservationDto, RecordingProgressDto, SubmitActivityDto } from './sessions.dto'; import { SessionsService } from './sessions.service';
@ApiBearerAuth() @ApiTags('Live Sessions') @Controller('sessions') export class SessionsController { constructor(private readonly service: SessionsService) {}
  @Get('upcoming') upcoming(@CurrentUser() user: Principal) { return this.service.upcoming(user); }
  @Get(':id') detail(@Param('id') id: string, @CurrentUser() user: Principal) { return this.service.detail(id, user); }
  @Post(':id/join-token') joinToken(@Param('id') id: string, @CurrentUser() user: Principal) { return this.service.joinToken(id, user); }
  @Post(':id/audio/grant') grantAudio(@Param('id') id: string, @Body() dto: AudioPermissionDto, @CurrentUser() user: Principal) { return this.service.audio(id, dto.studentId, true, user); }
  @Post(':id/audio/revoke') revokeAudio(@Param('id') id: string, @Body() dto: AudioPermissionDto, @CurrentUser() user: Principal) { return this.service.audio(id, dto.studentId, false, user); }
  @Post(':id/start') start(@Param('id') id: string, @CurrentUser() user: Principal) { return this.service.transition(id, SessionStatus.LIVE, user); }
  @Post(':id/complete') complete(@Param('id') id: string, @CurrentUser() user: Principal) { return this.service.transition(id, SessionStatus.COMPLETED, user); }
  @Post(':id/attendance/join') join(@Param('id') id: string, @CurrentUser() user: Principal) { return this.service.join(id, user); }
  @Post(':id/attendance/leave') leave(@Param('id') id: string, @CurrentUser() user: Principal) { return this.service.leave(id, user); }
  @Post(':id/attendance/override') override(@Param('id') id: string, @Body() dto: AttendanceOverrideDto, @CurrentUser() user: Principal) { return this.service.override(id, dto, user); }
  @Post(':id/messages') chat(@Param('id') id: string, @Body() dto: ChatDto, @CurrentUser() user: Principal) { return this.service.chat(id, dto, user); }
  @Get(':id/messages') messages(@Param('id') id: string, @Query('studentId') studentId: string, @CurrentUser() user: Principal) { return this.service.messages(id, studentId, user); }
  @Post(':id/assessments') assess(@Param('id') id: string, @Body() dto: AssessmentDto, @CurrentUser() user: Principal) { return this.service.assess(id, dto, user); }
  @Post(':id/observations') observe(@Param('id') id: string, @Body() dto: ObservationDto, @CurrentUser() user: Principal) { return this.service.observe(id, dto, user); }
  @Post(':id/breakouts') breakouts(@Param('id') id: string, @Body() dto: CreateBreakoutsDto, @CurrentUser() user: Principal) { return this.service.breakouts(id, dto, user); }
  @Post(':id/breakouts/start') startBreakouts(@Param('id') id: string, @CurrentUser() user: Principal) { return this.service.breakoutState(id, BreakoutStatus.ACTIVE, user); }
  @Post(':id/breakouts/end') endBreakouts(@Param('id') id: string, @CurrentUser() user: Principal) { return this.service.breakoutState(id, BreakoutStatus.ENDED, user); }
  @Get('recordings/:recordingId/playback') playback(@Param('recordingId') id: string, @CurrentUser() user: Principal) { return this.service.playback(id, user); }
  @Post('recordings/:recordingId/progress') progress(@Param('recordingId') id: string, @Body() dto: RecordingProgressDto, @CurrentUser() user: Principal) { return this.service.recordingProgress(id, dto, user); }
  @Post('activities/submissions') submitActivity(@Body() dto: SubmitActivityDto, @CurrentUser() user: Principal) { return this.service.submitActivity(dto, user); }
  @Post('activities/submissions/:submissionId/grade') gradeActivity(@Param('submissionId') id: string, @Body() dto: GradeActivityDto, @CurrentUser() user: Principal) { return this.service.gradeActivity(id, dto, user); }
}
