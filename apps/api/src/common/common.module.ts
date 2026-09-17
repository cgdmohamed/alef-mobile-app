import { Global, Module } from '@nestjs/common';
import { TenantAccessService } from './tenant-access.service';
import { EntitlementsService } from './entitlements.service';

@Global()
@Module({ providers: [TenantAccessService, EntitlementsService], exports: [TenantAccessService, EntitlementsService] })
export class CommonModule {}
