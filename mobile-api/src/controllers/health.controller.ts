import { Request, Response } from 'express';
import { isConnected } from '../config/database';
import { config } from '../config';
import { sendSuccess } from '../utils/apiResponse';

export async function healthCheck(_req: Request, res: Response): Promise<void> {
  const dbConnected = isConnected();
  const status = dbConnected ? 'ok' : 'degraded';

  sendSuccess(
    res,
    {
      status,
      service: config.SERVICE_NAME,
      version: '1.0.0',
      environment: config.NODE_ENV,
      database: dbConnected ? 'connected' : 'disconnected',
      timestamp: new Date().toISOString(),
    },
    dbConnected ? 200 : 503
  );
}

export async function getAppConfig(_req: Request, res: Response): Promise<void> {
  // Returns safe client-facing configuration (no secrets)
  sendSuccess(res, {
    sos: {
      coastGuard: config.SOS_COAST_GUARD_NUMBER || null,
      localAuthority: config.SOS_LOCAL_AUTHORITY_NUMBER || null,
      emergencyContact: config.SOS_EMERGENCY_CONTACT_NUMBER || null,
    },
    maxFileSizeMb: config.MAX_FILE_SIZE_MB,
  });
}
