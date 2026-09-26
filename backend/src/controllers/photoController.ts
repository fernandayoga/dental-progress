import { Response, NextFunction } from 'express';
import { photoService } from '../services/photoService.js';
import { sendSuccess, sendError } from '../utils/response.js';
import { AuthenticatedRequest } from '../middleware/authMiddleware.js';

export const uploadPhoto = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { patientId } = req.params;
    const { category, documentationDate, notes } = req.body;

    if (!req.file) {
      sendError(res, 'No photo uploaded', 400);
      return;
    }

    const hostUrl = `${req.protocol}://${req.get('host')}`;

    const photo = await photoService.uploadPhoto({
      patientId,
      dentistId: req.dentist?._id?.toString(),
      category,
      documentationDate,
      notes,
      fileBuffer: req.file.buffer,
      originalName: req.file.originalname,
      mimeType: req.file.mimetype,
      hostUrl,
    });

    sendSuccess(res, photo, 'Dental photo uploaded successfully', 201);
  } catch (error: any) {
    if (error.message && error.message.includes('Patient not found')) {
      sendError(res, error.message, 404);
      return;
    }
    next(error);
  }
};

export const getPatientPhotos = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { patientId } = req.params;
    const { sort } = req.query;

    const sortOrder = sort === 'asc' ? 'asc' : 'desc';
    const result = await photoService.getPatientPhotos(patientId, sortOrder);

    sendSuccess(res, {
      patient: result.patient,
      photos: result.photos,
    }, 'Patient photos retrieved successfully');
  } catch (error: any) {
    if (error.message && error.message.includes('Patient not found')) {
      sendError(res, error.message, 404);
      return;
    }
    next(error);
  }
};

export const getPhotoById = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const photo = await photoService.getPhotoById(id);

    if (!photo) {
      sendError(res, 'Photo not found', 404);
      return;
    }

    sendSuccess(res, photo, 'Photo retrieved successfully');
  } catch (error) {
    next(error);
  }
};

export const updatePhoto = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const { notes, category, documentationDate } = req.body;

    const updated = await photoService.updatePhoto(id, {
      notes,
      category,
      documentationDate,
    });

    if (!updated) {
      sendError(res, 'Photo not found', 404);
      return;
    }

    sendSuccess(res, updated, 'Photo updated successfully');
  } catch (error) {
    next(error);
  }
};

export const deletePhoto = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const deleted = await photoService.deletePhoto(id);

    if (!deleted) {
      sendError(res, 'Photo not found', 404);
      return;
    }

    sendSuccess(res, null, 'Photo deleted successfully');
  } catch (error) {
    next(error);
  }
};
