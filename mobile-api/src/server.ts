import { createApp } from './app';
import { connectDatabase, disconnectDatabase } from './config/database';
import { config } from './config';
import { logger } from './utils/logger';

async function main() {
  // Connect to MongoDB first — fail fast if unavailable
  await connectDatabase();

  const app = createApp();

  const server = app.listen(config.PORT, () => {
    logger.info(`🚀 KAIROS Mobile API running on port ${config.PORT}`, {
      env: config.NODE_ENV,
      swagger: config.NODE_ENV !== 'production' ? `http://localhost:${config.PORT}/api-docs` : 'disabled',
    });
  });

  // Graceful shutdown
  const shutdown = async (signal: string) => {
    logger.info(`Received ${signal}. Shutting down gracefully...`);
    server.close(async () => {
      await disconnectDatabase();
      logger.info('Server closed. Goodbye.');
      process.exit(0);
    });

    // Force exit after 10 seconds
    setTimeout(() => {
      logger.error('Graceful shutdown timeout. Force exiting.');
      process.exit(1);
    }, 10000);
  };

  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT', () => shutdown('SIGINT'));

  process.on('unhandledRejection', (reason) => {
    logger.error('Unhandled Promise Rejection', { reason });
  });

  process.on('uncaughtException', (error) => {
    logger.error('Uncaught Exception', { error });
    process.exit(1);
  });
}

main().catch((error) => {
  console.error('Failed to start server:', error);
  process.exit(1);
});
