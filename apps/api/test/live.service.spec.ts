import { ConfigService } from '@nestjs/config';
import { LiveService } from '../src/providers/live.service';

describe('LiveService', () => {
  const config = { getOrThrow: (key: string) => key === 'AGORA_APP_ID' ? '0'.repeat(32) : '1'.repeat(32) } as ConfigService;
  const service = new LiveService(config);

  it('issues different least-privilege tokens for publishers and subscribers', () => {
    const subscriber = service.token('session-1', 100, false);
    const publisher = service.token('session-1', 100, true);
    expect(subscriber.token).toMatch(/^007/);
    expect(publisher.token).toMatch(/^007/);
    expect(subscriber.token).not.toBe(publisher.token);
  });
});
