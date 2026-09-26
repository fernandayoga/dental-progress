import multer from 'multer';
import { Request } from 'express';

// Use memory storage for clean buffer streaming to Cloudinary
const storage = multer.memoryStorage();

// Allowed MIME types for dental clinical photos
const ALLOWED_MIME_TYPES = [
  'image/jpeg',
  'image/jpg',
  'image/png',
  'image/webp',
];

const fileFilter = (
  _req: Request,
  file: Express.Multer.File,
  cb: multer.FileFilterCallback
) => {
  if (ALLOWED_MIME_TYPES.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(
      new Error(
        `Invalid file format: ${file.mimetype}. Only JPEG, JPG, PNG, and WEBP dental photos are supported.`
      )
    );
  }
};

export const uploadSinglePhoto = multer({
  storage,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10 MB max file size
    files: 1,
  },
  fileFilter,
}).single('photo');

export const uploadMultiplePhotos = multer({
  storage,
  limits: {
    fileSize: 10 * 1024 * 1024,
    files: 5,
  },
  fileFilter,
}).array('photos', 5);
