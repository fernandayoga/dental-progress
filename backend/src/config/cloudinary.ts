import { v2 as cloudinary } from 'cloudinary';
import { config } from './env.js';
import { logger } from '../utils/logger.js';

if (config.cloudinary.isConfigured) {
  cloudinary.config({
    cloud_name: config.cloudinary.cloudName,
    api_key: config.cloudinary.apiKey,
    api_secret: config.cloudinary.apiSecret,
    secure: true,
  });
  logger.info('Cloudinary configured successfully for cloud:', config.cloudinary.cloudName);
} else {
  logger.warn(
    'Cloudinary credentials not provided in .env. Image uploads will use local secure storage fallback.'
  );
}

export { cloudinary };
