import { Injectable, ServiceUnavailableException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { cert, getApps, initializeApp } from 'firebase-admin/app';
import { getMessaging } from 'firebase-admin/messaging';

@Injectable()
export class PushService {
  private readonly configured: boolean;
  constructor(config: ConfigService) {
    const raw = config.getOrThrow<string>('FIREBASE_SERVICE_ACCOUNT_JSON');
    this.configured = !!raw;
    if (raw && !getApps().length) initializeApp({ credential: cert(JSON.parse(raw) as { projectId: string; clientEmail: string; privateKey: string }) });
  }
  async send(token: string, title: string, body: string, data?: Record<string, string>): Promise<void> {
    if (!this.configured) throw new ServiceUnavailableException('Firebase is not configured');
    await getMessaging().send({ token, notification: { title, body }, data });
  }
}
