import { Response } from 'express';
import { AuthenticatedRequest } from '../middleware/authenticate';
import { evidenceService } from '../services/EvidenceService';
import { sendSuccess } from '../utils/apiResponse';
import { createAuditLog } from '../services/AuditService';
import { AuditAction } from '../models/AuditLog';

export async function uploadEvidence(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { id: inspectionId } = req.params;

  if (!req.file) {
    res.status(400).json({
      success: false,
      error: { code: 'NO_FILE', message: 'No file was uploaded.' },
    });
    return;
  }

  const clientSha256 = req.body.sha256 || req.body.clientSha256;
  if (!clientSha256) {
    res.status(422).json({
      success: false,
      error: { code: 'MISSING_HASH', message: 'SHA-256 hash (sha256 field) is required for evidence integrity.' },
    });
    return;
  }

  const evidence = await evidenceService.upload(req, inspectionId, req.file, {
    clientSha256,
    capturedAt: req.body.capturedAt || new Date().toISOString(),
    latitude: req.body.latitude ? parseFloat(req.body.latitude) : undefined,
    longitude: req.body.longitude ? parseFloat(req.body.longitude) : undefined,
    accuracy: req.body.accuracy ? parseFloat(req.body.accuracy) : undefined,
    clientRequestId: req.body.clientRequestId,
  });

  await createAuditLog({
    userId: req.user!._id,
    action: AuditAction.CAPTURE_EVIDENCE,
    entityType: 'Evidence',
    entityId: evidence._id.toString(),
    metadata: { evidenceType: evidence.type, fileSize: evidence.fileSize },
  });

  sendSuccess(res, evidence, 201);
}

export async function listEvidence(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { id: inspectionId } = req.params;
  const list = await evidenceService.listForInspection(req, inspectionId);
  sendSuccess(res, list);
}

export async function getEvidenceById(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { id } = req.params;
  const evidence = await evidenceService.getById(req, id);
  sendSuccess(res, evidence);
}

export async function deleteEvidence(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { id } = req.params;
  await evidenceService.delete(req, id);

  await createAuditLog({
    userId: req.user!._id,
    action: AuditAction.DELETE_EVIDENCE,
    entityType: 'Evidence',
    entityId: id,
  });

  sendSuccess(res, null, 200, 'Evidence deleted.');
}
