import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { Dentist, IDentist } from '../models/Dentist.js';
import { config } from '../config/env.js';
import { logger } from '../utils/logger.js';

export interface TokenPayload {
  dentistId: string;
  email: string;
}

export class AuthService {
  /**
   * Hashes a plain-text password using bcrypt
   */
  async hashPassword(password: string): Promise<string> {
    const salt = await bcrypt.genSalt(10);
    return bcrypt.hash(password, salt);
  }

  /**
   * Compares a plain password against the stored bcrypt hash
   */
  async comparePassword(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash);
  }

  /**
   * Generates a signed JWT token
   */
  generateToken(payload: TokenPayload): string {
    return jwt.sign(payload, config.jwtSecret, {
      expiresIn: config.jwtExpiresIn,
    } as jwt.SignOptions);
  }

  /**
   * Verifies a JWT token
   */
  verifyToken(token: string): TokenPayload {
    return jwt.verify(token, config.jwtSecret) as TokenPayload;
  }

  /**
   * Seeds an initial dentist account if database has no dentists
   */
  async seedInitialDentist(): Promise<void> {
    const count = await Dentist.countDocuments();
    if (count === 0) {
      const defaultEmail = 'dentist@dentalprogress.com';
      const defaultPassword = 'password123';
      const passwordHash = await this.hashPassword(defaultPassword);

      await Dentist.create({
        name: 'Dr. Sarah Jenkins, DDS',
        email: defaultEmail,
        passwordHash,
      });

      logger.info('Created default dentist account:');
      logger.info(`  Email: ${defaultEmail}`);
      logger.info(`  Password: ${defaultPassword}`);
    }
  }
}

export const authService = new AuthService();
