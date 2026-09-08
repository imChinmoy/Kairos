import { Request, Response } from 'express';
import { authService } from '../services/AuthService';
import { AuthenticatedRequest } from '../middleware/authenticate';
import { loginSchema, refreshSchema, logoutSchema } from '../validators/auth.validators';
import { sendSuccess, sendError } from '../utils/apiResponse';
import { createAuditLog } from '../services/AuditService';
import { AuditAction } from '../models/AuditLog';

export async function login(req: Request, res: Response): Promise<void> {
  const body = loginSchema.parse(req.body);

  try {
    const result = await authService.login(body.identifier, body.password);

    await createAuditLog({
      userId: result.user._id,
      action: AuditAction.LOGIN,
      ipAddress: req.ip,
      userAgent: req.headers['user-agent'],
    });

    sendSuccess(res, {
      user: result.user,
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    });
  } catch (error) {
    await createAuditLog({
      action: AuditAction.LOGIN_FAILED,
      ipAddress: req.ip,
      metadata: { identifier: body.identifier },
    });
    throw error;
  }
}

export async function refresh(req: Request, res: Response): Promise<void> {
  const body = refreshSchema.parse(req.body);
  const tokens = await authService.refresh(body.refreshToken);
  sendSuccess(res, tokens);
}

export async function logout(req: Request, res: Response): Promise<void> {
  const body = logoutSchema.parse(req.body);
  await authService.logout(body.refreshToken);

  const user = (req as AuthenticatedRequest).user;
  if (user) {
    await createAuditLog({
      userId: user._id,
      action: AuditAction.LOGOUT,
      ipAddress: req.ip,
    });
  }

  sendSuccess(res, null, 200, 'Logged out successfully.');
}

export async function getMe(req: AuthenticatedRequest, res: Response): Promise<void> {
  sendSuccess(res, req.user);
}
