import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import path from 'path';
import 'express-async-errors';

import { config } from './config';
import { errorHandler } from './middleware/errorHandler';
import { defaultLimiter } from './middleware/rateLimiter';
import { logger } from './utils/logger';

// Routes
import authRoutes from './routes/auth.routes';
import investigationRoutes from './routes/investigation.routes';
import inspectionRoutes from './routes/inspection.routes';
import evidenceRoutes from './routes/evidence.routes';
import sosRoutes from './routes/sos.routes';
import { healthCheck, getAppConfig } from './controllers/health.controller';

// Swagger
import swaggerJsdoc from 'swagger-jsdoc';
import swaggerUi from 'swagger-ui-express';

const swaggerSpec = swaggerJsdoc({
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'KAIROS Mobile API',
      version: '1.0.0',
      description: 'Field Investigation API for the KAIROS Oil Spill Intelligence Platform',
    },
    servers: [{ url: `http://localhost:${config.PORT}`, description: 'Development' }],
    components: {
      securitySchemes: {
        BearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' },
      },
    },
    security: [{ BearerAuth: [] }],
  },
  apis: ['./src/routes/*.ts'],
});

export function createApp(): express.Application {
  const app = express();

  // Security headers
  app.use(helmet({
    crossOriginResourcePolicy: { policy: 'cross-origin' }, // Allow serving uploaded files
  }));

  // CORS
  const allowedOrigins = config.CORS_ORIGIN.split(',').map((o) => o.trim());
  app.use(
    cors({
      origin: (origin, callback) => {
        if (!origin || allowedOrigins.includes(origin) || allowedOrigins.includes('*')) {
          callback(null, true);
        } else {
          callback(new Error(`CORS policy: ${origin} is not allowed.`));
        }
      },
      credentials: true,
    })
  );

  // Body parsing
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true, limit: '10mb' }));

  // HTTP request logging
  app.use(
    morgan('combined', {
      stream: { write: (message) => logger.info(message.trim()) },
      skip: (_req, res) => config.NODE_ENV === 'test',
    })
  );

  // Global rate limiting
  app.use(defaultLimiter);

  // Serve uploaded files statically
  app.use('/uploads', express.static(path.resolve(config.UPLOAD_DIR)));

  // Swagger docs
  if (config.NODE_ENV !== 'production') {
    app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));
  }

  // Health & config endpoints (no auth required)
  app.get('/api/v1/health', healthCheck);
  app.get('/api/v1/config', getAppConfig);

  // API routes
  app.use('/api/v1/auth', authRoutes);
  app.use('/api/v1/investigations', investigationRoutes);
  app.use('/api/v1/inspections', inspectionRoutes);
  app.use('/api/v1/evidence', evidenceRoutes);
  app.use('/api/v1/observations', (req, _res, next) => {
    // Proxy /observations/:id to inspection controller
    next();
  });
  app.use('/api/v1/sos', sosRoutes);

  // 404 handler
  app.use((req, res) => {
    res.status(404).json({
      success: false,
      error: { code: 'NOT_FOUND', message: `Route ${req.method} ${req.path} not found.` },
    });
  });

  // Global error handler (must be last)
  app.use(errorHandler);

  return app;
}
