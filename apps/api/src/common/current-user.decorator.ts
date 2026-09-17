import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { Principal } from './principal';

export const CurrentUser = createParamDecorator((_: unknown, context: ExecutionContext): Principal => {
  return context.switchToHttp().getRequest<{ user: Principal }>().user;
});
