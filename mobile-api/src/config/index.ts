import * as dotenv from 'dotenv';
import { z } from 'zod';

dotenv.config();

const configSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.string().default('3000').transform(Number),
  SERVICE_NAME: z.string().default('kairos-mobile-api'),

  // MongoDB — required; fail clearly if missing/invalid
  MONGO_URI: z.string().min(10, 'MONGO_URI is required and must be a valid MongoDB connection string'),

  // JWT
  JWT_SECRET: z.string().min(32, 'JWT_SECRET must be at least 32 characters'),
  JWT_EXPIRES_IN: z.string().default('15m'),
  JWT_REFRESH_EXPIRES_IN: z.string().default('7d'),

  // CORS
  CORS_ORIGIN: z.string().default('http://localhost:3000'),

  // FastAPI
  FASTAPI_BASE_URL: z.string().url('FASTAPI_BASE_URL must be a valid URL').default('http://localhost:8080'),

  // File Storage
  FILE_STORAGE_MODE: z.enum(['local', 's3', 'gcs', 'cloudinary']).default('local'),
  UPLOAD_DIR: z.string().default('./uploads'),
  MAX_FILE_SIZE_MB: z.string().default('25').transform(Number),

  // AWS S3 (optional)
  AWS_REGION: z.string().optional(),
  AWS_ACCESS_KEY_ID: z.string().optional(),
  AWS_SECRET_ACCESS_KEY: z.string().optional(),
  AWS_S3_BUCKET: z.string().optional(),

  // GCS (optional)
  GCS_BUCKET: z.string().optional(),
  GCS_KEY_FILE: z.string().optional(),

  // Cloudinary (optional)
  CLOUDINARY_CLOUD_NAME: z.string().optional(),
  CLOUDINARY_API_KEY: z.string().optional(),
  CLOUDINARY_API_SECRET: z.string().optional(),

  // Map providers
  GOOGLE_MAPS_API_KEY: z.string().optional(),
  MAPBOX_ACCESS_TOKEN: z.string().optional(),

  // SOS — loaded from env, served to app via config endpoint
  SOS_COAST_GUARD_NUMBER: z.string().optional(),
  SOS_LOCAL_AUTHORITY_NUMBER: z.string().optional(),
  SOS_EMERGENCY_CONTACT_NUMBER: z.string().optional(),

  // Rate Limiting
  RATE_LIMIT_WINDOW_MS: z.string().default('900000').transform(Number),
  RATE_LIMIT_MAX_REQUESTS: z.string().default('100').transform(Number),

  // Logging
  LOG_LEVEL: z.enum(['error', 'warn', 'info', 'debug']).default('info'),
});

const parsed = configSchema.safeParse(process.env);

if (!parsed.success) {
  console.error('❌ KAIROS API — Invalid environment configuration:');
  const errors = parsed.error.flatten().fieldErrors;
  Object.entries(errors).forEach(([key, messages]) => {
    console.error(`  ${key}: ${messages?.join(', ')}`);
  });
  process.exit(1);
}

export const config = parsed.data;

export type Config = typeof config;
