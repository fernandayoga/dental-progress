import { Request, Response, NextFunction } from 'express';
import { Dentist } from '../models/Dentist.js';
import { authService } from '../services/authService.js';
import { sendSuccess, sendError } from '../utils/response.js';
import { AuthenticatedRequest } from '../middleware/authMiddleware.js';

export const register = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { name, email, password } = req.body;

    const existingDentist = await Dentist.findOne({ email: email.toLowerCase().trim() });
    if (existingDentist) {
      sendError(res, 'An account with this email already exists.', 409);
      return;
    }

    const passwordHash = await authService.hashPassword(password);
    const dentist = await Dentist.create({
      name: name.trim(),
      email: email.toLowerCase().trim(),
      passwordHash,
    });

    const token = authService.generateToken({
      dentistId: dentist._id.toString(),
      email: dentist.email,
    });

    sendSuccess(
      res,
      {
        dentist: {
          id: dentist._id,
          name: dentist.name,
          email: dentist.email,
        },
        token,
      },
      'Dentist registered successfully',
      201
    );
  } catch (error) {
    next(error);
  }
};

export const login = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { email, password } = req.body;

    const dentist = await Dentist.findOne({ email: email.toLowerCase().trim() });
    if (!dentist) {
      sendError(res, 'Invalid email or password.', 401);
      return;
    }

    const isMatch = await authService.comparePassword(password, dentist.passwordHash);
    if (!isMatch) {
      sendError(res, 'Invalid email or password.', 401);
      return;
    }

    const token = authService.generateToken({
      dentistId: dentist._id.toString(),
      email: dentist.email,
    });

    sendSuccess(
      res,
      {
        dentist: {
          id: dentist._id,
          name: dentist.name,
          email: dentist.email,
        },
        token,
      },
      'Login successful'
    );
  } catch (error) {
    next(error);
  }
};

export const getMe = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    if (!req.dentist) {
      sendError(res, 'Not authenticated', 401);
      return;
    }

    sendSuccess(res, {
      id: req.dentist._id,
      name: req.dentist.name,
      email: req.dentist.email,
      createdAt: req.dentist.createdAt,
    });
  } catch (error) {
    next(error);
  }
};
