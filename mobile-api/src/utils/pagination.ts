import { PaginationMeta } from './apiResponse';

export interface PaginationQuery {
  page?: string | number;
  limit?: string | number;
}

export interface PaginationOptions {
  page: number;
  limit: number;
  skip: number;
}

export function parsePagination(query: PaginationQuery, maxLimit = 100): PaginationOptions {
  const page = Math.max(1, parseInt(String(query.page || '1'), 10));
  const limit = Math.min(maxLimit, Math.max(1, parseInt(String(query.limit || '20'), 10)));
  const skip = (page - 1) * limit;
  return { page, limit, skip };
}

export function buildPaginationMeta(
  page: number,
  limit: number,
  total: number
): PaginationMeta {
  const totalPages = Math.ceil(total / limit);
  return {
    page,
    limit,
    total,
    totalPages,
    hasNext: page < totalPages,
    hasPrevious: page > 1,
  };
}
