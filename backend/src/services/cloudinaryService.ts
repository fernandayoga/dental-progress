import { cloudinary } from '../config/cloudinary.js';
import { config } from '../config/env.js';
import { logger } from '../utils/logger.js';
import fs from 'fs';
import path from 'path';
import crypto from 'crypto';

export interface UploadResult {
  publicId: string;
  secureUrl: string;
  width?: number;
  height?: number;
  format?: string;
}

export class CloudinaryService {
  private localUploadDir = path.resolve(process.cwd(), 'uploads');

  constructor() {
    if (!config.cloudinary.isConfigured) {
      if (!fs.existsSync(this.localUploadDir)) {
        fs.mkdirSync(this.localUploadDir, { recursive: true });
      }
    }
  }

  /**
   * Uploads an image buffer to Cloudinary or falls back to local storage
   */
  async uploadPhoto(
    fileBuffer: Buffer,
    patientId: string,
    originalName: string,
    mimeType: string,
    hostUrl: string
  ): Promise<UploadResult> {
    const uniqueId = `dp_${Date.now()}_${crypto.randomBytes(4).toString('hex')}`;

    if (config.cloudinary.isConfigured) {
      return new Promise<UploadResult>((resolve, reject) => {
        const uploadStream = cloudinary.uploader.upload_stream(
          {
            folder: `${config.cloudinary.folder}/patients/${patientId}`,
            public_id: uniqueId,
            resource_type: 'image',
            transformation: [{ quality: 'auto:good' }, { fetch_format: 'auto' }],
          },
          (error, result) => {
            if (error || !result) {
              logger.error('Cloudinary upload error:', error);
              return reject(new Error(error?.message || 'Failed to upload photo to Cloudinary'));
            }
            resolve({
              publicId: result.public_id,
              secureUrl: result.secure_url,
              width: result.width,
              height: result.height,
              format: result.format,
            });
          }
        );
        uploadStream.end(fileBuffer);
      });
    }

    // Local disk fallback for development if Cloudinary credentials are not present
    const ext = path.extname(originalName) || (mimeType === 'image/png' ? '.png' : '.jpg');
    const patientDir = path.join(this.localUploadDir, patientId);
    if (!fs.existsSync(patientDir)) {
      fs.mkdirSync(patientDir, { recursive: true });
    }
    const filename = `${uniqueId}${ext}`;
    const filePath = path.join(patientDir, filename);

    await fs.promises.writeFile(filePath, fileBuffer);

    const publicId = `local_${patientId}_${filename}`;
    const secureUrl = `${hostUrl}/uploads/${patientId}/${filename}`;

    logger.info(`Photo saved locally: ${filePath} -> ${secureUrl}`);
    return {
      publicId,
      secureUrl,
    };
  }

  /**
   * Deletes a photo from Cloudinary or local storage
   */
  async deletePhoto(publicId: string): Promise<boolean> {
    try {
      if (publicId.startsWith('local_')) {
        const parts = publicId.split('_');
        if (parts.length >= 3) {
          const patientId = parts[1];
          const filename = parts.slice(2).join('_');
          const filePath = path.join(this.localUploadDir, patientId, filename);
          if (fs.existsSync(filePath)) {
            await fs.promises.unlink(filePath);
            logger.info(`Deleted local photo: ${filePath}`);
          }
        }
        return true;
      }

      if (config.cloudinary.isConfigured) {
        const result = await cloudinary.uploader.destroy(publicId);
        logger.info(`Deleted photo from Cloudinary: ${publicId}`, result);
        return result.result === 'ok';
      }

      return true;
    } catch (error) {
      logger.error(`Error deleting photo with publicId ${publicId}:`, error);
      return false;
    }
  }

  /**
   * Deletes multiple photos by their public IDs
   */
  async deletePhotos(publicIds: string[]): Promise<void> {
    await Promise.all(publicIds.map((id) => this.deletePhoto(id)));
  }
}

export const cloudinaryService = new CloudinaryService();
