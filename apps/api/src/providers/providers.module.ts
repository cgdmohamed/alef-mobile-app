import { Global, Module } from '@nestjs/common'; import { EmailService } from './email.service'; import { LiveService } from './live.service'; import { StorageService } from './storage.service';
import { RecordingProviderService } from './recording.service';
import { PushService } from './push.service';
@Global() @Module({ providers: [StorageService, EmailService, LiveService, RecordingProviderService, PushService], exports: [StorageService, EmailService, LiveService, RecordingProviderService, PushService] }) export class ProvidersModule {}
