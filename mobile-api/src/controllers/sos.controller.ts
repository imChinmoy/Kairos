import { Response } from 'express';
import { AuthenticatedRequest } from '../middleware/authenticate';
import { SosEvent } from '../models/SosEvent';
import { sendSuccess } from '../utils/apiResponse';
import { createAuditLog } from '../services/AuditService';
import { AuditAction } from '../models/AuditLog';
import { sosSchema } from '../validators/inspection.validators';
import mongoose from 'mongoose';

export async function triggerSos(req: AuthenticatedRequest, res: Response): Promise<void> {
  const body = sosSchema.parse(req.body);

  const sosEvent = await SosEvent.create({
    officerId: req.user!._id,
    fastApiInvestigationId: body.fastApiInvestigationId,
    inspectionId: body.inspectionId ? new mongoose.Types.ObjectId(body.inspectionId) : undefined,
    triggeredAt: new Date(),
    location:
      body.latitude !== undefined
        ? { latitude: body.latitude, longitude: body.longitude, accuracy: body.accuracy }
        : undefined,
    contactType: body.contactType,
    notes: body.notes,
  });

  await createAuditLog({
    userId: req.user!._id,
    action: AuditAction.SOS_TRIGGERED,
    entityType: 'SosEvent',
    entityId: sosEvent._id.toString(),
    ipAddress: req.ip,
    metadata: { contactType: body.contactType, location: sosEvent.location },
  });

  sendSuccess(res, sosEvent, 201, 'SOS event recorded. Emergency services will be notified.');
}

export async function getSosHistory(req: AuthenticatedRequest, res: Response): Promise<void> {
  const events = await SosEvent.find({ officerId: req.user!._id })
    .sort({ triggeredAt: -1 })
    .limit(20)
    .lean();
  sendSuccess(res, events);
}
