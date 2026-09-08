import rateLimit from 'express-rate-limit';
import { config } from '../config';
import { sendError } from '../utils/apiResponse';
import { Request, Response } from 'express';

export const defaultLimiter = rateLimit({
  windowMs: config.RATE_LIMIT_WINDOW_MS,
  max: config.RATE_LIMIT_MAX_REQUESTS,
  standardHeaders: true,
  legacyHeaders: false,
  handler: (_req: Request, res: Response) => {
    sendError(res, 429, 'RATE_LIMIT_EXCEEDED', 'Too many requests. Please try again later.');
  },
});

// Stricter limiter for auth endpoints
export const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  handler: (_req: Request, res: Response) => {
    sendError(
      res,
      429,
      'AUTH_RATE_LIMIT_EXCEEDED',
      'Too many authentication attempts. Please wait 15 minutes before trying again.'
    );
  },
});

// Upload limiter
export const uploadLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 30,
  standardHeaders: true,
  legacyHeaders: false,
  handler: (_req: Request, res: Response) => {
    sendError(res, 429, 'UPLOAD_RATE_LIMIT_EXCEEDED', 'Too many uploads. Please slow down.');
  },
});
