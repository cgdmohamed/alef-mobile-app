import { Controller, Get, ServiceUnavailableException } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import Redis from 'ioredis';
import { Public } from '../common/public.decorator';
import { PrismaService } from '../database/prisma.service';

@ApiTags('Operations')
@Controller()
export class HealthController {
  private readonly redis: Redis;

  constructor(private readonly prisma: PrismaService, config: ConfigService) {
    this.redis = new Redis(config.getOrThrow<string>('REDIS_URL'), { lazyConnect: true, maxRetriesPerRequest: 1, enableReadyCheck: true });
  }

  @Public()
  @Get('health')
  health() { return { status: 'ok' }; }

  @Public()
  @Get('ready')
  async ready() {
    try {
      await this.prisma.$queryRaw`SELECT 1`;
      if (this.redis.status === 'wait') await this.redis.connect();
      await this.redis.ping();
      return { status: 'ready', checks: { postgres: 'up', redis: 'up' } };
    } catch {
      throw new ServiceUnavailableException('A required dependency is unavailable');
    }
  }
}
