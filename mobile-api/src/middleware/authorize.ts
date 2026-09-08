import { Response, NextFunction } from 'express';
import { UserRole } from '../models/User';
import { AuthenticatedRequest } from './authenticate';
import { sendError } from '../utils/apiResponse';

/**
 * Middleware factory: restrict access to specific roles.
 * Usage: router.get('/admin-only', authenticateUser, authorizeRoles(UserRole.ADMIN))
 */
export function authorizeRoles(...roles: UserRole[]) {
  return (req: AuthenticatedRequest, res: Response, next: NextFunction): void => {
    if (!req.user) {
      sendError(res, 401, 'UNAUTHENTICATED', 'You must be logged in.');
      return;
    }

    if (!roles.includes(req.user.role as UserRole)) {
      sendError(
        res,
        403,
        'INSUFFICIENT_PERMISSIONS',
        'You do not have permission to perform this action.'
      );
      return;
    }

    next();
  };
}

/**
 * Returns true if the authenticated user is a supervisor or admin
 */
export function isSupervisorOrAdmin(req: AuthenticatedRequest): boolean {
  return req.user?.role === UserRole.SUPERVISOR || req.user?.role === UserRole.ADMIN;
}
