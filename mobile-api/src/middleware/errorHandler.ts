import { Request, Response, NextFunction } from 'express';
import { ZodError } from 'zod';
import { logger } from '../utils/logger';
import { sendError } from '../utils/apiResponse';

export class AppError extends Error {
  public statusCode: number;
  public code: string;
  public details?: unknown;

  constructor(statusCode: number, code: string, message: string, details?: unknown) {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
    this.details = details;
    this.name = 'AppError';
  }
}

// eslint-disable-next-line @typescript-eslint/no-unused-vars
export function errorHandler(
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction
): void {
  // Structured AppError
  if (err instanceof AppError) {
    sendError(res, err.statusCode, err.code, err.message, err.details);
    return;
  }

  // Zod validation error
  if (err instanceof ZodError) {
    sendError(
      res,
      422,
      'VALIDATION_ERROR',
      'Request validation failed.',
      err.flatten().fieldErrors
    );
    return;
  }

  // Mongoose duplicate key
  if ((err as { code?: number }).code === 11000) {
    const keyValue = (err as { keyValue?: Record<string, unknown> }).keyValue;
    sendError(
      res,
      409,
      'DUPLICATE_ENTRY',
      `A record with this ${Object.keys(keyValue || {}).join(', ')} already exists.`
    );
    return;
  }

  // Mongoose validation error
  if (err.name === 'ValidationError') {
    sendError(res, 422, 'MONGOOSE_VALIDATION', err.message);
    return;
  }

  // Mongoose cast error (invalid ObjectId)
  if (err.name === 'CastError') {
    sendError(res, 400, 'INVALID_ID', 'The provided ID is not valid.');
    return;
  }

  // Multer file size error
  if (err.message === 'File too large') {
    sendError(res, 413, 'FILE_TOO_LARGE', `File size exceeds the maximum allowed limit.`);
    return;
  }

  // Unexpected error
  logger.error('Unhandled server error', {
    error: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
  });

  sendError(res, 500, 'INTERNAL_SERVER_ERROR', 'An unexpected error occurred. Please try again later.');
}
