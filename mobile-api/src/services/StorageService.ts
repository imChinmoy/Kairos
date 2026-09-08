import fs from 'fs';
import path from 'path';
import { v4 as uuidv4 } from 'uuid';
import { config } from '../config';
import { logger } from '../utils/logger';
import { hashFile } from '../utils/hashUtils';

export interface UploadResult {
  storagePath: string;
  remoteUrl: string;
  serverSha256: string;
  fileSize: number;
}

export interface StorageAdapter {
  upload(buffer: Buffer, fileName: string, mimeType: string): Promise<UploadResult>;
  delete(storagePath: string): Promise<void>;
  getUrl(storagePath: string): string;
}

// ─── Local Filesystem Adapter ───────────────────────────────────────────────

class LocalStorageAdapter implements StorageAdapter {
  private uploadDir: string;

  constructor() {
    this.uploadDir = path.resolve(config.UPLOAD_DIR);
    if (!fs.existsSync(this.uploadDir)) {
      fs.mkdirSync(this.uploadDir, { recursive: true });
    }
  }

  async upload(buffer: Buffer, originalName: string, _mimeType: string): Promise<UploadResult> {
    const ext = path.extname(originalName);
    const uniqueName = `${uuidv4()}${ext}`;
    const filePath = path.join(this.uploadDir, uniqueName);

    fs.writeFileSync(filePath, buffer);

    const serverSha256 = await hashFile(filePath);
    const fileSize = buffer.length;

    logger.debug('File saved to local storage', { filePath, fileSize });

    return {
      storagePath: filePath,
      remoteUrl: `/uploads/${uniqueName}`,
      serverSha256,
      fileSize,
    };
  }

  async delete(storagePath: string): Promise<void> {
    if (fs.existsSync(storagePath)) {
      fs.unlinkSync(storagePath);
      logger.debug('File deleted from local storage', { storagePath });
    }
  }

  getUrl(storagePath: string): string {
    return `/uploads/${path.basename(storagePath)}`;
  }
}

// ─── Cloudinary Adapter ────────────────────────────────────────────────────────

import { v2 as cloudinary } from 'cloudinary';

class CloudinaryStorageAdapter implements StorageAdapter {
  constructor() {
    cloudinary.config({
      cloud_name: config.CLOUDINARY_CLOUD_NAME,
      api_key: config.CLOUDINARY_API_KEY,
      api_secret: config.CLOUDINARY_API_SECRET,
    });
  }

  async upload(buffer: Buffer, originalName: string, mimeType: string): Promise<UploadResult> {
    return new Promise((resolve, reject) => {
      const uploadStream = cloudinary.uploader.upload_stream(
        {
          folder: 'kairos_evidence',
          resource_type: 'auto',
          use_filename: true,
          unique_filename: true,
        },
        async (error, result) => {
          if (error) {
            logger.error('Cloudinary upload failed', { error });
            return reject(error);
          }

          if (!result) {
            return reject(new Error('Cloudinary upload returned null'));
          }

          try {
            // Write temp file to compute hash (or we can pass the buffer hash)
            const serverSha256 = await hashFileFromBuffer(buffer);
            
            resolve({
              storagePath: result.public_id,
              remoteUrl: result.secure_url,
              serverSha256,
              fileSize: buffer.length,
            });
          } catch (hashError) {
            reject(hashError);
          }
        }
      );

      uploadStream.end(buffer);
    });
  }

  async delete(storagePath: string): Promise<void> {
    try {
      await cloudinary.uploader.destroy(storagePath);
      logger.debug('File deleted from Cloudinary', { storagePath });
    } catch (error) {
      logger.error('Failed to delete from Cloudinary', { storagePath, error });
    }
  }

  getUrl(storagePath: string): string {
    return cloudinary.url(storagePath, { secure: true });
  }
}

// Helper to hash buffer
import crypto from 'crypto';
async function hashFileFromBuffer(buffer: Buffer): Promise<string> {
  const hashSum = crypto.createHash('sha256');
  hashSum.update(buffer);
  return hashSum.digest('hex');
}

// ─── Factory ─────────────────────────────────────────────────────────────────

function createStorageAdapter(): StorageAdapter {
  switch (config.FILE_STORAGE_MODE) {
    case 'local':
      return new LocalStorageAdapter();
    case 'cloudinary':
      return new CloudinaryStorageAdapter();
    default:
      logger.warn(`Unknown FILE_STORAGE_MODE "${config.FILE_STORAGE_MODE}", defaulting to local`);
      return new LocalStorageAdapter();
  }
}

export const storageService = createStorageAdapter();
