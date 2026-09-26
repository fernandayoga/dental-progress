import { Request, Response, NextFunction } from 'express';
import { sendError } from '../utils/response.js';

export const validateLogin = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const { email, password } = req.body;
  const errors: Record<string, string> = {};

  if (!email || typeof email !== 'string' || !email.trim()) {
    errors.email = 'Email address is required.';
  } else if (!/^\S+@\S+\.\S+$/.test(email.trim())) {
    errors.email = 'Please provide a valid email address.';
  }

  if (!password || typeof password !== 'string' || password.length === 0) {
    errors.password = 'Password is required.';
  }

  if (Object.keys(errors).length > 0) {
    sendError(res, 'Validation failed', 400, errors);
    return;
  }

  next();
};

export const validateRegister = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const { name, email, password } = req.body;
  const errors: Record<string, string> = {};

  if (!name || typeof name !== 'string' || name.trim().length < 2) {
    errors.name = 'Full name is required (minimum 2 characters).';
  }

  if (!email || typeof email !== 'string' || !email.trim()) {
    errors.email = 'Email address is required.';
  } else if (!/^\S+@\S+\.\S+$/.test(email.trim())) {
    errors.email = 'Please enter a valid email address.';
  }

  if (!password || typeof password !== 'string' || password.length < 6) {
    errors.password = 'Password must be at least 6 characters.';
  }

  if (Object.keys(errors).length > 0) {
    sendError(res, 'Validation failed', 400, errors);
    return;
  }

  next();
};

export const validatePatient = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const { name, dateOfBirth, gender, phone } = req.body;
  const errors: Record<string, string> = {};

  if (!name || typeof name !== 'string' || name.trim().length === 0) {
    errors.name = 'Patient full name is required.';
  }

  if (!dateOfBirth) {
    errors.dateOfBirth = 'Date of birth is required.';
  } else {
    const dob = new Date(dateOfBirth);
    if (isNaN(dob.getTime())) {
      errors.dateOfBirth = 'Invalid date of birth.';
    }
  }

  const validGenders = ['Male', 'Female', 'Other'];
  if (!gender || !validGenders.includes(gender)) {
    errors.gender = 'Gender must be one of: Male, Female, Other.';
  }

  if (!phone || typeof phone !== 'string' || phone.trim().length === 0) {
    errors.phone = 'Phone number is required.';
  }

  if (Object.keys(errors).length > 0) {
    sendError(res, 'Validation failed', 400, errors);
    return;
  }

  next();
};

export const validatePhotoUpload = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  if (!req.file) {
    sendError(res, 'A dental photo file is required for upload.', 400);
    return;
  }
  next();
};
