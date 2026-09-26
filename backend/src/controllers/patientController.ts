import { Response, NextFunction } from 'express';
import { patientService } from '../services/patientService.js';
import { sendSuccess, sendError } from '../utils/response.js';
import { AuthenticatedRequest } from '../middleware/authMiddleware.js';

export const getPatients = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { search, page, limit } = req.query;

    const result = await patientService.getPatients({
      search: typeof search === 'string' ? search : undefined,
      page: page ? parseInt(page as string, 10) : 1,
      limit: limit ? parseInt(limit as string, 10) : 20,
    });

    sendSuccess(res, result.patients, 'Patients retrieved successfully', 200, {
      total: result.total,
      page: result.page,
      totalPages: result.totalPages,
    });
  } catch (error) {
    next(error);
  }
};

export const getPatientById = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const patient = await patientService.getPatientById(id);

    if (!patient) {
      sendError(res, 'Patient not found', 404);
      return;
    }

    sendSuccess(res, patient, 'Patient retrieved successfully');
  } catch (error) {
    next(error);
  }
};

export const createPatient = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { name, dateOfBirth, gender, phone, additionalInformation } = req.body;

    const patient = await patientService.createPatient({
      name,
      dateOfBirth,
      gender,
      phone,
      additionalInformation,
      dentistId: req.dentist?._id?.toString(),
    });

    sendSuccess(res, patient, 'Patient registered successfully', 201);
  } catch (error) {
    next(error);
  }
};

export const updatePatient = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const { name, dateOfBirth, gender, phone, additionalInformation } = req.body;

    const updated = await patientService.updatePatient(id, {
      name,
      dateOfBirth,
      gender,
      phone,
      additionalInformation,
    });

    if (!updated) {
      sendError(res, 'Patient not found', 404);
      return;
    }

    sendSuccess(res, updated, 'Patient updated successfully');
  } catch (error) {
    next(error);
  }
};

export const deletePatient = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const success = await patientService.deletePatient(id);

    if (!success) {
      sendError(res, 'Patient not found', 404);
      return;
    }

    sendSuccess(res, null, 'Patient and associated photos deleted successfully');
  } catch (error) {
    next(error);
  }
};
