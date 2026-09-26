import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import path from 'path';
import authRoutes from './routes/authRoutes.js';
import patientRoutes from './routes/patientRoutes.js';
import photoRoutes from './routes/photoRoutes.js';
import dashboardRoutes from './routes/dashboardRoutes.js';
import { errorHandler } from './middleware/errorHandler.js';
import { sendSuccess } from './utils/response.js';

export const createApp = (): Application => {
  const app = express();

  // Middleware
  app.use(cors({
    origin: '*',
    methods: ['GET', 'POST', 'PATCH', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  }));
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true, limit: '10mb' }));

  // Static files for local image storage fallback
  const uploadsDir = path.resolve(process.cwd(), 'uploads');
  app.use('/uploads', express.static(uploadsDir));

  // Health check endpoint
  app.get('/api/health', (_req: Request, res: Response) => {
    sendSuccess(res, {
      status: 'healthy',
      service: 'Dental Progress API',
      timestamp: new Date().toISOString(),
    });
  });

  // API Routes
  app.use('/api/auth', authRoutes);
  app.use('/api/patients', patientRoutes);
  app.use('/api/photos', photoRoutes);
  app.use('/api/dashboard', dashboardRoutes);

  // 404 Handler
  app.use((req: Request, res: Response) => {
    res.status(404).json({
      success: false,
      message: `Route not found: ${req.method} ${req.originalUrl}`,
    });
  });

  // Centralized Error Handler
  app.use(errorHandler);

  return app;
};
