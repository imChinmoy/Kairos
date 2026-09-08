import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config';
import { User, IUser } from '../models/User';
import { sendError } from '../utils/apiResponse';

export interface AuthenticatedRequest extends Request {
  user?: IUser;
}

interface JwtPayload {
  sub: string;  // userId
  role: string;
  employeeId: string;
  iat: number;
  exp: number;
}

export async function authenticateUser(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    sendError(res, 401, 'MISSING_TOKEN', 'Authentication token is required.');
    return;
  }

  const token = authHeader.split(' ')[1];

  try {
    const payload = jwt.verify(token, config.JWT_SECRET) as JwtPayload;

    const user = await User.findById(payload.sub).select('+isActive').lean();

    if (!user) {
      sendError(res, 401, 'USER_NOT_FOUND', 'User account not found.');
      return;
    }

    if (!user.isActive) {
      sendError(res, 401, 'ACCOUNT_DISABLED', 'Your account has been disabled. Contact your administrator.');
      return;
    }

    // Attach full user object to request
    req.user = user as unknown as IUser;
    next();
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      sendError(res, 401, 'TOKEN_EXPIRED', 'Your session has expired. Please log in again.');
      return;
    }
    if (error instanceof jwt.JsonWebTokenError) {
      sendError(res, 401, 'INVALID_TOKEN', 'Invalid authentication token.');
      return;
    }
    next(error);
  }
}
