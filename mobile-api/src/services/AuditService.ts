import { AuditLog, AuditAction } from '../models/AuditLog';
import mongoose from 'mongoose';
import { logger } from '../utils/logger';

interface AuditParams {
  userId?: string | mongoose.Types.ObjectId;
  action: AuditAction;
  entityType?: string;
  entityId?: string;
  ipAddress?: string;
  userAgent?: string;
  metadata?: Record<string, unknown>;
}

export async function createAuditLog(params: AuditParams): Promise<void> {
  try {
    await AuditLog.create({
      userId: params.userId ? new mongoose.Types.ObjectId(params.userId.toString()) : undefined,
      action: params.action,
      entityType: params.entityType,
      entityId: params.entityId,
      timestamp: new Date(),
      ipAddress: params.ipAddress,
      userAgent: params.userAgent,
      metadata: params.metadata,
    });
  } catch (error) {
    // Audit log failures should never break the main request flow
    logger.error('Failed to create audit log', { error, params });
  }
}
