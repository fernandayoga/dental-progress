import { createApp } from './app.js';
import { config } from './config/env.js';
import { connectDatabase, disconnectDatabase } from './config/db.js';
import { authService } from './services/authService.js';
import { logger } from './utils/logger.js';

const startServer = async () => {
  try {
    // 1. Connect to MongoDB
    await connectDatabase();

    // 2. Seed initial demo dentist if no accounts exist
    await authService.seedInitialDentist();

    // 3. Create and start Express app
    const app = createApp();
    const server = app.listen(config.port, '0.0.0.0', () => {
      logger.info(`===============================================`);
      logger.info(` Dental Progress API is running`);
      logger.info(` Server URL: http://localhost:${config.port}`);
      logger.info(` Environment: ${config.nodeEnv}`);
      logger.info(` Health check: http://localhost:${config.port}/api/health`);
      logger.info(`===============================================`);
    });

    const shutdown = async () => {
      logger.info('Shutting down server gracefully...');
      server.close(async () => {
        await disconnectDatabase();
        logger.info('Server closed. Database disconnected.');
        process.exit(0);
      });
    };

    process.on('SIGTERM', shutdown);
    process.on('SIGINT', shutdown);
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
};

startServer();
