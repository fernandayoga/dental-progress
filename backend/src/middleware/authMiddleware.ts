import { Request, Response, NextFunction } from 'express';
import { authService, TokenPayload } from '../services/authService.js';
import { Dentist, IDentist } from '../models/Dentist.js';
import { sendError } from '../utils/response.js';

export interface AuthenticatedRequest extends Request {
  dentist?: IDentist;
  tokenPayload?: TokenPayload;
}

export const authenticateJwt = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    sendError(res, 'Authentication required. No token provided.', 401);
    return;
  }

  const token = authHeader.split(' ')[1];

  try {
    const payload = authService.verifyToken(token);
    const dentist = await Dentist.findById(payload.dentistId);

    if (!dentist) {
      sendError(res, 'Dentist account not found or deactivated.', 401);
      return;
    }

    req.dentist = dentist;
    req.tokenPayload = payload;
    next();
  } catch (error) {
    sendError(res, 'Invalid or expired session token.', 401);
  }
};
