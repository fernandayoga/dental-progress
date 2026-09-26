import { Response, NextFunction } from 'express';
import { Patient } from '../models/Patient.js';
import { Photo } from '../models/Photo.js';
import { sendSuccess } from '../utils/response.js';
import { AuthenticatedRequest } from '../middleware/authMiddleware.js';

export const getDashboardStats = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const totalPatients = await Patient.countDocuments();
    const totalPhotos = await Photo.countDocuments();

    // Fetch the 5 most recently added patients
    const recentPatients = await Patient.find()
      .sort({ createdAt: -1 })
      .limit(5);

    // Fetch the 5 most recently uploaded photos
    const recentPhotos = await Photo.find()
      .sort({ createdAt: -1 })
      .limit(5)
      .populate('patientId', 'patientId name');

    sendSuccess(res, {
      totalPatients,
      totalPhotos,
      recentPatients,
      recentPhotos,
      dentistName: req.dentist?.name,
    }, 'Dashboard statistics retrieved successfully');
  } catch (error) {
    next(error);
  }
};
