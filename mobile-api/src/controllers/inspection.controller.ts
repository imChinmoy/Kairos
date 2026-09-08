import { Response } from 'express';
import { AuthenticatedRequest } from '../middleware/authenticate';
import { inspectionService } from '../services/InspectionService';
import { FieldObservation } from '../models/FieldObservation';
import { sendSuccess, sendError } from '../utils/apiResponse';
import { createAuditLog } from '../services/AuditService';
import { AuditAction } from '../models/AuditLog';
import {
  arrivalLocationSchema,
  createObservationSchema,
} from '../validators/inspection.validators';
import { z } from 'zod';

const createInspectionSchema = z.object({
  clientRequestId: z.string().optional(),
});

// ─── Inspection Controllers ────────────────────────────────────────────────────

export async function createInspection(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { id: fastApiInvestigationId } = req.params;
  const body = createInspectionSchema.parse(req.body);

  const inspection = await inspectionService.createInspection(
    req,
    fastApiInvestigationId,
    body.clientRequestId
  );

  sendSuccess(res, inspection, 201);
}

export async function getInspection(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { id: fastApiInvestigationId } = req.params;
  const inspection = await inspectionService.getInspection(req, fastApiInvestigationId);

  if (!inspection) {
    sendError(res, 404, 'INSPECTION_NOT_FOUND', 'No inspection found for this investigation.');
    return;
  }

  sendSuccess(res, inspection);
}

export async function updateInspection(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { id: inspectionId } = req.params;
  const inspection = await inspectionService.updateInspection(req, inspectionId, req.body);
  sendSuccess(res, inspection);
}

export async function startInspection(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { id: inspectionId } = req.params;
  const inspection = await inspectionService.startInspection(req, inspectionId);

  await createAuditLog({
    userId: req.user!._id,
    action: AuditAction.START_INSPECTION,
    entityType: 'FieldInspection',
    entityId: inspectionId,
    ipAddress: req.ip,
  });

  sendSuccess(res, inspection, 200, 'Inspection started.');
}

export async function recordArrival(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { id: inspectionId } = req.params;
  const body = arrivalLocationSchema.parse(req.body);
  const inspection = await inspectionService.recordArrival(req, inspectionId, body);
  sendSuccess(res, inspection, 200, 'Arrival recorded.');
}

export async function submitInspection(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { id: inspectionId } = req.params;
  const inspection = await inspectionService.submitInspection(req, inspectionId);

  await createAuditLog({
    userId: req.user!._id,
    action: AuditAction.SUBMIT_INSPECTION,
    entityType: 'FieldInspection',
    entityId: inspectionId,
    ipAddress: req.ip,
  });

  sendSuccess(res, inspection, 200, 'Inspection submitted successfully.');
}

// ─── Observation Controllers ──────────────────────────────────────────────────

export async function createObservation(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { id: inspectionId } = req.params;
  const body = createObservationSchema.parse(req.body);

  const inspection = await inspectionService.getInspectionById(inspectionId);
  if (!inspection) {
    sendError(res, 404, 'INSPECTION_NOT_FOUND', 'Inspection not found.');
    return;
  }

  await inspectionService.verifyOwnership(req, inspection);

  // Idempotency
  if (body.clientRequestId) {
    const existing = await FieldObservation.findOne({ clientRequestId: body.clientRequestId }).lean();
    if (existing) {
      sendSuccess(res, existing, 200);
      return;
    }
  }

  const observation = await FieldObservation.create({
    fastApiInvestigationId: inspection.fastApiInvestigationId,
    inspectionId,
    officerId: req.user!._id,
    type: body.type,
    value: body.value,
    timestamp: new Date(body.timestamp),
    latitude: body.latitude,
    longitude: body.longitude,
    accuracy: body.accuracy,
    notes: body.notes,
    clientRequestId: body.clientRequestId,
  });

  await createAuditLog({
    userId: req.user!._id,
    action: AuditAction.ADD_OBSERVATION,
    entityType: 'FieldObservation',
    entityId: observation._id.toString(),
  });

  sendSuccess(res, observation, 201);
}

export async function getObservations(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { id: inspectionId } = req.params;

  const inspection = await inspectionService.getInspectionById(inspectionId);
  if (!inspection) {
    sendError(res, 404, 'INSPECTION_NOT_FOUND', 'Inspection not found.');
    return;
  }
  await inspectionService.verifyOwnership(req, inspection);

  const observations = await FieldObservation.find({ inspectionId })
    .sort({ timestamp: -1 })
    .lean();

  sendSuccess(res, observations);
}

export async function updateObservation(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { id: observationId } = req.params;

  const observation = await FieldObservation.findById(observationId);
  if (!observation) {
    sendError(res, 404, 'OBSERVATION_NOT_FOUND', 'Observation not found.');
    return;
  }

  if (observation.officerId.toString() !== req.user!._id.toString()) {
    sendError(res, 403, 'OBSERVATION_ACCESS_DENIED', 'You do not have access to this observation.');
    return;
  }

  Object.assign(observation, req.body);
  await observation.save();
  sendSuccess(res, observation);
}

export async function deleteObservation(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { id: observationId } = req.params;

  const observation = await FieldObservation.findById(observationId);
  if (!observation) {
    sendError(res, 404, 'OBSERVATION_NOT_FOUND', 'Observation not found.');
    return;
  }

  if (observation.officerId.toString() !== req.user!._id.toString()) {
    sendError(res, 403, 'OBSERVATION_ACCESS_DENIED', 'You do not have access to this observation.');
    return;
  }

  await observation.deleteOne();
  sendSuccess(res, null, 200, 'Observation deleted.');
}
