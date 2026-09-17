import { DeleteObjectCommand, GetObjectCommand, PutObjectCommand, S3Client } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { Injectable, ServiceUnavailableException } from '@nestjs/common'; import { ConfigService } from '@nestjs/config';
@Injectable() export class StorageService {
  private readonly client: S3Client; private readonly bucket: string;
  constructor(config: ConfigService) { const accessKeyId = config.getOrThrow<string>('S3_ACCESS_KEY'); const secretAccessKey = config.getOrThrow<string>('S3_SECRET_KEY'); this.bucket = config.getOrThrow<string>('S3_BUCKET'); this.client = new S3Client({ endpoint: config.getOrThrow<string>('S3_ENDPOINT'), region: config.getOrThrow<string>('S3_REGION'), forcePathStyle: true, credentials: accessKeyId && secretAccessKey ? { accessKeyId, secretAccessKey } : undefined }); }
  private configured() { if (!this.client.config.credentials) throw new ServiceUnavailableException('Object storage is not configured'); }
  async uploadUrl(key: string, contentType: string) { this.configured(); return getSignedUrl(this.client, new PutObjectCommand({ Bucket: this.bucket, Key: key, ContentType: contentType }), { expiresIn: 900 }); }
  async downloadUrl(key: string) { this.configured(); return getSignedUrl(this.client, new GetObjectCommand({ Bucket: this.bucket, Key: key }), { expiresIn: 900 }); }
  async put(key: string, body: Buffer, contentType: string): Promise<void> { this.configured(); await this.client.send(new PutObjectCommand({ Bucket: this.bucket, Key: key, Body: body, ContentType: contentType })); }
  async delete(key: string): Promise<void> { this.configured(); await this.client.send(new DeleteObjectCommand({ Bucket: this.bucket, Key: key })); }
}
