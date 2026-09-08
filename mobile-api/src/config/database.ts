import mongoose from 'mongoose';
import { config } from './index';
import { logger } from '../utils/logger';

const MAX_RETRIES = 5;
const RETRY_DELAY_MS = 3000;

let retryCount = 0;

async function connectWithRetry(): Promise<void> {
  try {
    await mongoose.connect(config.MONGO_URI, {
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
    });

    retryCount = 0;
    logger.info('✅ MongoDB connected', {
      uri: config.MONGO_URI.replace(/\/\/.*@/, '//***@'), // Mask credentials in logs
      db: mongoose.connection.name,
    });
  } catch (error) {
    retryCount++;
    logger.error(`❌ MongoDB connection failed (attempt ${retryCount}/${MAX_RETRIES})`, {
      error: error instanceof Error ? error.message : String(error),
    });

    if (retryCount >= MAX_RETRIES) {
      logger.error('MongoDB max retries exceeded. Exiting.');
      process.exit(1);
    }

    logger.info(`Retrying MongoDB connection in ${RETRY_DELAY_MS}ms...`);
    await new Promise((res) => setTimeout(res, RETRY_DELAY_MS));
    return connectWithRetry();
  }
}

export async function connectDatabase(): Promise<void> {
  mongoose.connection.on('disconnected', () => {
    logger.warn('MongoDB disconnected. Attempting to reconnect...');
    connectWithRetry();
  });

  mongoose.connection.on('error', (err) => {
    logger.error('MongoDB connection error', { error: err.message });
  });

  await connectWithRetry();
}

export async function disconnectDatabase(): Promise<void> {
  await mongoose.connection.close();
  logger.info('MongoDB connection closed.');
}

export function isConnected(): boolean {
  return mongoose.connection.readyState === 1;
}

export { mongoose };
