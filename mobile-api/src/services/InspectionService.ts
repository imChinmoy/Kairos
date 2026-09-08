import { FieldInspection, InspectionStatus, IFieldInspection } from '../models/FieldInspection';
import { InvestigationAssignment } from '../models/InvestigationAssignment';
import { AppError } from '../middleware/errorHandler';
import { AuthenticatedRequest } from '../middleware/authenticate';
import { isSupervisorOrAdmin } from '../middleware/authorize';
import { UserRole } from '../models/User';
import mongoose from 'mongoose';

export class InspectionService {

  /**
   * Verify the requesting officer owns this inspection (or is admin/supervisor).
   */
  async verifyOwnership(req: AuthenticatedRequest, inspection: IFieldInspection): Promise<void> {
    if (isSupervisorOrAdmin(req)) return;

    if (inspection.officerId.toString() !== req.user!._id.toString()) {
      throw new AppError(403, 'INSPECTION_ACCESS_DENIED', 'You do not have access to this inspection.');
    }
  }

  async createInspection(
    req: AuthenticatedRequest,
    fastApiInvestigationId: string,
    clientRequestId?: string
  ): Promise<IFieldInspection> {
    // Verify officer is assigned to this investigation
    if (req.user!.role === UserRole.OFFICER) {
      const assignment = await InvestigationAssignment.findOne({
        fastApiInvestigationId,
        officerId: req.user!._id,
      });
      if (!assignment) {
        throw new AppError(403, 'NOT_ASSIGNED', 'You are not assigned to this investigation.');
      }
    }

    // Idempotency check
    if (clientRequestId) {
      const existing = await FieldInspection.findOne({ clientRequestId });
      if (existing) return existing;
    }

    // Check for existing active inspection
    const existingActive = await FieldInspection.findOne({
      fastApiInvestigationId,
      officerId: req.user!._id,
      status: { $nin: [InspectionStatus.SUBMITTED, InspectionStatus.SYNCED] },
    });

    if (existingActive) {
      return existingActive;
    }

    return FieldInspection.create({
      fastApiInvestigationId,
      officerId: req.user!._id,
      status: InspectionStatus.NOT_STARTED,
      clientRequestId,
    });
  }

  async getInspection(req: AuthenticatedRequest, fastApiInvestigationId: string): Promise<IFieldInspection | null> {
    const query: Record<string, unknown> = { fastApiInvestigationId };

    if (req.user!.role === UserRole.OFFICER) {
      query.officerId = req.user!._id;
    }

    return FieldInspection.findOne(query).lean() as unknown as Promise<IFieldInspection | null>;
  }

  async getInspectionById(id: string): Promise<IFieldInspection | null> {
    return FieldInspection.findById(id).lean() as unknown as Promise<IFieldInspection | null>;
  }

  async updateInspection(
    req: AuthenticatedRequest,
    inspectionId: string,
    updates: Partial<IFieldInspection>
  ): Promise<IFieldInspection> {
    const inspection = await FieldInspection.findById(inspectionId);
    if (!inspection) throw new AppError(404, 'INSPECTION_NOT_FOUND', 'Inspection not found.');

    await this.verifyOwnership(req, inspection);

    if (inspection.status === InspectionStatus.SUBMITTED || inspection.status === InspectionStatus.SYNCED) {
      throw new AppError(409, 'INSPECTION_SUBMITTED', 'Cannot modify a submitted inspection.');
    }

    Object.assign(inspection, updates);
    if (inspection.status === InspectionStatus.NOT_STARTED) {
      inspection.status = InspectionStatus.DRAFT;
    }
    await inspection.save();
    return inspection;
  }

  async startInspection(req: AuthenticatedRequest, inspectionId: string): Promise<IFieldInspection> {
    const inspection = await FieldInspection.findById(inspectionId);
    if (!inspection) throw new AppError(404, 'INSPECTION_NOT_FOUND', 'Inspection not found.');

    await this.verifyOwnership(req, inspection);

    if (!([InspectionStatus.NOT_STARTED, InspectionStatus.DRAFT] as string[]).includes(inspection.status)) {
      throw new AppError(409, 'ALREADY_STARTED', 'Inspection has already been started.');
    }

    inspection.status = InspectionStatus.IN_PROGRESS;
    inspection.startedAt = new Date();
    await inspection.save();
    return inspection;
  }

  async recordArrival(
    req: AuthenticatedRequest,
    inspectionId: string,
    location: { latitude: number; longitude: number; accuracy?: number; altitude?: number }
  ): Promise<IFieldInspection> {
    const inspection = await FieldInspection.findById(inspectionId);
    if (!inspection) throw new AppError(404, 'INSPECTION_NOT_FOUND', 'Inspection not found.');

    await this.verifyOwnership(req, inspection);

    inspection.arrivalLocation = {
      ...location,
      timestamp: new Date(),
    };

    if (inspection.status === InspectionStatus.NOT_STARTED) {
      inspection.status = InspectionStatus.IN_PROGRESS;
      inspection.startedAt = new Date();
    }

    await inspection.save();
    return inspection;
  }

  async submitInspection(req: AuthenticatedRequest, inspectionId: string): Promise<IFieldInspection> {
    const inspection = await FieldInspection.findById(inspectionId);
    if (!inspection) throw new AppError(404, 'INSPECTION_NOT_FOUND', 'Inspection not found.');

    await this.verifyOwnership(req, inspection);

    if (inspection.status === InspectionStatus.SUBMITTED || inspection.status === InspectionStatus.SYNCED) {
      throw new AppError(409, 'ALREADY_SUBMITTED', 'Inspection is already submitted.');
    }

    inspection.status = InspectionStatus.SUBMITTED;
    inspection.submittedAt = new Date();
    inspection.completedAt = new Date();
    await inspection.save();

    // Update assignment status
    await InvestigationAssignment.findOneAndUpdate(
      {
        fastApiInvestigationId: inspection.fastApiInvestigationId,
        officerId: req.user!._id,
      },
      { status: 'COMPLETED', completedAt: new Date() }
    );

    return inspection;
  }
}

export const inspectionService = new InspectionService();
