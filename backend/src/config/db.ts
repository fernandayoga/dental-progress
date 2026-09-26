import mongoose from 'mongoose';
import { MongoMemoryServer } from 'mongodb-memory-server';
import { config } from './env.js';
import { logger } from '../utils/logger.js';

let mongod: MongoMemoryServer | null = null;

export const connectDatabase = async (): Promise<void> => {
  try {
    // Set mongoose strictQuery
    mongoose.set('strictQuery', true);

    // Try connecting to configured MONGO_URI with a 3-second server selection timeout
    logger.info(`Attempting connection to MongoDB at: ${config.mongoUri}`);
    await mongoose.connect(config.mongoUri, {
      serverSelectionTimeoutMS: 3000,
    });
    logger.info('Connected to MongoDB database successfully.');
  } catch (error) {
    logger.warn('Could not connect to external MongoDB server. Starting in-memory MongoDB server for development/testing...');
    try {
      mongod = await MongoMemoryServer.create();
      const memoryUri = mongod.getUri();
      await mongoose.connect(memoryUri);
      logger.info(`Connected to In-Memory MongoDB successfully: ${memoryUri}`);
    } catch (innerError) {
      logger.error('Failed to initialize in-memory MongoDB:', innerError);
      throw innerError;
    }
  }

  mongoose.connection.on('error', (err) => {
    logger.error('MongoDB connection error:', err);
  });

  mongoose.connection.on('disconnected', () => {
    logger.warn('MongoDB connection disconnected.');
  });
};

export const disconnectDatabase = async (): Promise<void> => {
  await mongoose.disconnect();
  if (mongod) {
    await mongod.stop();
  }
};
