import { ExtensionScope, PlacementType, ProgramItemType } from '@prisma/client';
import { IsEnum, IsObject, IsOptional, IsString, IsUUID, MinLength } from 'class-validator';
export class CreateExtensionDto {
  @IsUUID() programVersionId!: string;
  @IsEnum(ExtensionScope) scope!: ExtensionScope;
  @IsOptional() @IsUUID() runId?: string;
  @IsOptional() @IsUUID() unitId?: string;
  @IsOptional() @IsUUID() anchorItemId?: string;
  @IsEnum(PlacementType) placement!: PlacementType;
  @IsEnum(ProgramItemType) itemType!: ProgramItemType;
  @IsString() @MinLength(1) title!: string;
  @IsOptional() @IsObject() content?: Record<string, unknown>;
}
