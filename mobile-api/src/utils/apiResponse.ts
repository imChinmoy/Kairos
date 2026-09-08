import { Response } from 'express';

export interface ApiSuccessResponse<T = unknown> {
  success: true;
  data: T;
  message?: string;
}

export interface ApiErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
    details?: unknown;
  };
}

export interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
  hasNext: boolean;
  hasPrevious: boolean;
}

export interface PaginatedResponse<T> {
  success: true;
  data: T[];
  pagination: PaginationMeta;
}

export function sendSuccess<T>(res: Response, data: T, statusCode = 200, message?: string): Response {
  return res.status(statusCode).json({
    success: true,
    data,
    ...(message ? { message } : {}),
  } as ApiSuccessResponse<T>);
}

export function sendPaginated<T>(
  res: Response,
  data: T[],
  pagination: PaginationMeta
): Response {
  return res.status(200).json({
    success: true,
    data,
    pagination,
  } as PaginatedResponse<T>);
}

export function sendError(
  res: Response,
  statusCode: number,
  code: string,
  message: string,
  details?: unknown
): Response {
  return res.status(statusCode).json({
    success: false,
    error: {
      code,
      message,
      ...(details !== undefined ? { details } : {}),
    },
  } as ApiErrorResponse);
}
