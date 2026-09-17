import { ArgumentsHost, Catch, ExceptionFilter, HttpException, HttpStatus } from '@nestjs/common';
import { Request, Response } from 'express';

@Catch()
export class HttpErrorFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost): void {
    const response = host.switchToHttp().getResponse<Response>();
    const request = host.switchToHttp().getRequest<Request & { id?: string }>();
    const status = exception instanceof HttpException ? exception.getStatus() : HttpStatus.INTERNAL_SERVER_ERROR;
    const value = exception instanceof HttpException ? exception.getResponse() : null;
    const message = typeof value === 'string' ? value : value && typeof value === 'object' && 'message' in value ? value.message : 'Internal server error';
    response.status(status).json({ statusCode: status, message, path: request.url, requestId: request.id, timestamp: new Date().toISOString() });
  }
}
