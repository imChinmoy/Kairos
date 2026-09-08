import multer from 'multer';
import { Request } from 'express';
import { config } from '../config';
import { Evidence, EvidenceType, EvidenceSyncStatus } from '../models/Evidence';
import { FieldInspection } from '../models/FieldInspection';
import { AppError } from '../middleware/errorHandler';
import { AuthenticatedRequest } from '../middleware/authenticate';
import { isSupervisorOrAdmin } from '../middleware/authorize';
import { storageService } from './StorageService';
import { compareHashes } from '../utils/hashUtils';
import { logger } from '../utils/logger';
import { UserRole } from '../models/User';

const ALLOWED_MIME_TYPES: Record<EvidenceType, string[]> = {
  PHOTO: ['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/heif'],
  VIDEO: ['video/mp4', 'video/quicktime', 'video/x-msvideo', 'video/mpeg'],
  AUDIO: ['audio/mpeg', 'audio/wav', 'audio/ogg', 'audio/mp4', 'audio/aac'],
  DOCUMENT: ['application/pdf', 'application/msword', 'text/plain'],
  OTHER: ['application/octet-stream'],
};

function detectEvidenceType(mimeType: string): EvidenceType {
  if (mimeType.startsWith('image/')) return EvidenceType.PHOTO;
  if (mimeType.startsWith('video/')) return EvidenceType.VIDEO;
  if (mimeType.startsWith('audio/')) return EvidenceType.AUDIO;
  if (mimeType === 'application/pdf') return EvidenceType.DOCUMENT;
  return EvidenceType.OTHER;
}

function isAllowedMime(mimeType: string, type: EvidenceType): boolean {
  return ALLOWED_MIME_TYPES[type]?.includes(mimeType) ?? false;
}

// Multer configuration — store in memory for SHA-256 verification before disk write
export const evidenceUpload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: config.MAX_FILE_SIZE_MB * 1024 * 1024,
  },
  fileFilter: (_req: Request, file, cb) => {
    const type = detectEvidenceType(file.mimetype);
    const allAllowed = Object.values(ALLOWED_MIME_TYPES).flat();
    if (allAllowed.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error(`File type not allowed: ${file.mimetype}`));
    }
  },
});

export class EvidenceService {
  async verifyOwnership(req: AuthenticatedRequest, inspectionId: string): Promise<void> {
    if (isSupervisorOrAdmin(req)) return;

    const inspection = await FieldInspection.findById(inspectionId).lean();
    if (!inspection) throw new AppError(404, 'INSPECTION_NOT_FOUND', 'Inspection not found.');

    if (inspection.officerId.toString() !== req.user!._id.toString()) {
      throw new AppError(403, 'EVIDENCE_ACCESS_DENIED', 'You do not have access to this inspection.');
    }
  }

  async upload(
    req: AuthenticatedRequest,
    inspectionId: string,
    file: Express.Multer.File,
    metadata: {
      clientSha256: string;
      capturedAt: string;
      latitude?: number;
      longitude?: number;
      accuracy?: number;
      clientRequestId?: string;
    }
  ) {
    await this.verifyOwnership(req, inspectionId);

    // Idempotency
    if (metadata.clientRequestId) {
      const existing = await Evidence.findOne({ clientRequestId: metadata.clientRequestId });
      if (existing) return existing;
    }

    const inspection = await FieldInspection.findById(inspectionId).lean();
    if (!inspection) throw new AppError(404, 'INSPECTION_NOT_FOUND', 'Inspection not found.');

    const evidenceType = detectEvidenceType(file.mimetype);

    // Validate MIME type against expected type
    if (!isAllowedMime(file.mimetype, evidenceType)) {
      throw new AppError(422, 'INVALID_FILE_TYPE', `File type ${file.mimetype} is not allowed.`);
    }

    // Upload to storage
    const uploadResult = await storageService.upload(file.buffer, file.originalname, file.mimetype);

    // SHA-256 verification — compare client hash against server-computed hash
    const hashValid = compareHashes(metadata.clientSha256.toLowerCase(), uploadResult.serverSha256.toLowerCase());

    if (!hashValid) {
      // Delete the file to avoid storing corrupted evidence
      await storageService.delete(uploadResult.storagePath);
      logger.warn('Evidence SHA-256 mismatch', {
        clientSha256: metadata.clientSha256,
        serverSha256: uploadResult.serverSha256,
        inspectionId,
        officerId: req.user!._id,
      });
      throw new AppError(
        422,
        'HASH_MISMATCH',
        'Evidence integrity check failed. The uploaded file does not match the provided SHA-256 hash. Please re-upload.'
      );
    }

    const evidence = await Evidence.create({
      fastApiInvestigationId: inspection.fastApiInvestigationId,
      inspectionId,
      officerId: req.user!._id,
      type: evidenceType,
      fileName: file.originalname,
      mimeType: file.mimetype,
      fileSize: uploadResult.fileSize,
      storagePath: uploadResult.storagePath,
      remoteUrl: uploadResult.remoteUrl,
      clientSha256: metadata.clientSha256,
      serverSha256: uploadResult.serverSha256,
      hashVerified: true,
      capturedAt: new Date(metadata.capturedAt),
      location:
        metadata.latitude !== undefined
          ? { latitude: metadata.latitude, longitude: metadata.longitude, accuracy: metadata.accuracy }
          : undefined,
      syncStatus: EvidenceSyncStatus.SYNCED,
      clientRequestId: metadata.clientRequestId,
    });

    return evidence;
  }

  async listForInspection(req: AuthenticatedRequest, inspectionId: string) {
    await this.verifyOwnership(req, inspectionId);
    return Evidence.find({ inspectionId }).sort({ capturedAt: -1 }).lean();
  }

  async getById(req: AuthenticatedRequest, evidenceId: string) {
    const evidence = await Evidence.findById(evidenceId).lean();
    if (!evidence) throw new AppError(404, 'EVIDENCE_NOT_FOUND', 'Evidence not found.');

    if (!isSupervisorOrAdmin(req) && evidence.officerId.toString() !== req.user!._id.toString()) {
      throw new AppError(403, 'EVIDENCE_ACCESS_DENIED', 'You do not have access to this evidence.');
    }

    return evidence;
  }

  async delete(req: AuthenticatedRequest, evidenceId: string) {
    const evidence = await Evidence.findById(evidenceId);
    if (!evidence) throw new AppError(404, 'EVIDENCE_NOT_FOUND', 'Evidence not found.');

    if (!isSupervisorOrAdmin(req) && evidence.officerId.toString() !== req.user!._id.toString()) {
      throw new AppError(403, 'EVIDENCE_ACCESS_DENIED', 'You do not have access to this evidence.');
    }

    // Delete file from storage
    try {
      await storageService.delete(evidence.storagePath);
    } catch (error) {
      logger.warn('Could not delete evidence file from storage', { error, storagePath: evidence.storagePath });
    }

    await evidence.deleteOne();
  }
}

export const evidenceService = new EvidenceService();
