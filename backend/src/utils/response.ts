import { Response } from 'express';

export interface ApiResponse<T = unknown> {
  success: boolean;
  message?: string;
  data?: T;
  errors?: unknown;
  meta?: {
    page?: number;
    limit?: number;
    total?: number;
    totalPages?: number;
  };
}

export const sendSuccess = <T>(
  res: Response,
  data?: T,
  message?: string,
  statusCode: number = 200,
  meta?: ApiResponse['meta']
): Response => {
  const payload: ApiResponse<T> = {
    success: true,
    ...(message ? { message } : {}),
    ...(data !== undefined ? { data } : {}),
    ...(meta ? { meta } : {}),
  };
  return res.status(statusCode).json(payload);
};

export const sendError = (
  res: Response,
  message: string = 'An error occurred',
  statusCode: number = 500,
  errors?: unknown
): Response => {
  const payload: ApiResponse = {
    success: false,
    message,
    ...(errors !== undefined ? { errors } : {}),
  };
  return res.status(statusCode).json(payload);
};
