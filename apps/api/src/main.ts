import { ConsoleLogger, ValidationPipe, VersioningType } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import helmet from 'helmet';
import { randomUUID } from 'node:crypto';
import { AppModule } from './app.module';
import { HttpErrorFilter } from './common/http-exception.filter';

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create(AppModule, { bufferLogs: true });
  const config = app.get(ConfigService);
  app.useLogger(new ConsoleLogger({ json: config.get('NODE_ENV') === 'production', timestamp: true }));
  app.use(helmet());
  app.use((request: { id?: string; headers: Record<string, string | string[] | undefined> }, response: { setHeader(name: string, value: string): void }, next: () => void) => {
    request.id = typeof request.headers['x-request-id'] === 'string' ? request.headers['x-request-id'] : randomUUID();
    response.setHeader('x-request-id', request.id);
    next();
  });
  app.enableCors({ origin: config.getOrThrow<string>('ALLOWED_ORIGINS').split(',').map((origin) => origin.trim()), credentials: true });
  app.enableShutdownHooks();
  app.enableVersioning({ type: VersioningType.URI, defaultVersion: '1' });
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true }));
  app.useGlobalFilters(new HttpErrorFilter());

  const document = SwaggerModule.createDocument(app, new DocumentBuilder().setTitle('Alif Future API').setDescription('REST API for the Alif Future Learning Platform').setVersion('1.0').addBearerAuth().build());
  SwaggerModule.setup('docs', app, document);
  await app.listen(config.getOrThrow<number>('PORT'), '0.0.0.0');
}

void bootstrap();
