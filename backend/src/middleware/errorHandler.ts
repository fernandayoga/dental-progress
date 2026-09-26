import { Request, Response, NextFunction } from 'express';
import multer from 'multer';
import { sendError } from '../utils/response.js';
import { logger } from '../utils/logger.js';
import { config } from '../config/env.js';

export const errorHandler = (
  err: any,
  _req: Request,
  res: Response,
  _next: NextFunction
): void => {
  logger.error('Unhandled error caught by middleware:', err);

  // Multer Errors
  if (err instanceof multer.MulterError) {
    if (err.code === 'LIMIT_FILE_SIZE') {
      sendError(res, 'File size exceeds maximum allowed limit (10MB).', 400);
      return;
    }
    sendError(res, `Upload error: ${err.message}`, 400);
    return;
  }

  // File filter custom error
  if (err.message && err.message.startsWith('Invalid file format')) {
    sendError(res, err.message, 400);
    return;
  }

  // Mongoose CastError (invalid ObjectId)
  if (err.name === 'CastError') {
    sendError(res, `Resource not found with id ${err.value}`, 404);
    return;
  }

  // Mongoose ValidationError
  if (err.name === 'ValidationError') {
    const messages = Object.values(err.errors).map((val: any) => val.message);
    sendError(res, 'Validation error', 400, messages);
    return;
  }

  // MongoDB duplicate key error (code 11000)
  if (err.code === 11000) {
    const field = Object.keys(err.keyValue || {})[0] || 'field';
    sendError(res, `A record with this ${field} already exists.`, 409);
    return;
  }

  const statusCode = err.statusCode || 500;
  const message = config.nodeEnv === 'production' && statusCode === 500
    ? 'Internal server error. Please try again later.'
    : err.message || 'Internal server error';

  sendError(res, message, statusCode);
};
