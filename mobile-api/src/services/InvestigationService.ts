import { InvestigationAssignment, AssignmentStatus } from '../models/InvestigationAssignment';
import { FastApiDatabase, FastApiFullInvestigation } from '../models/FastApiCollections';
import { AppError } from '../middleware/errorHandler';
import { isSupervisorOrAdmin } from '../middleware/authorize';
import { AuthenticatedRequest } from '../middleware/authenticate';
import { parsePagination, buildPaginationMeta } from '../utils/pagination';
import { User, UserRole } from '../models/User';
import mongoose from 'mongoose';
import { NotificationService } from './NotificationService';

export interface InvestigationListQuery {
  page?: string;
  limit?: string;
  status?: string;
  priority?: string;
  sortBy?: string;
  sortOrder?: string;
  search?: string;
}

export class InvestigationService {

  /**
   * Get paginated list of investigations for the authenticated user.
   * Officers only see investigations assigned to them.
   * Supervisors/Admins see all.
   */
  async listForUser(req: AuthenticatedRequest, query: InvestigationListQuery) {
    const user = req.user!;
    const { page, limit, skip } = parsePagination(query);

    const filter: Record<string, unknown> = {};

    // Officers are scoped to their assignments
    if (user.role === UserRole.OFFICER) {
      filter.officerId = user._id;
    }

    if (query.status && Object.values(AssignmentStatus).includes(query.status as AssignmentStatus)) {
      filter.status = query.status;
    }

    if (query.priority) {
      filter.priority = query.priority.toUpperCase();
    }

    const sortField = query.sortBy || 'assignedAt';
    const sortOrder = query.sortOrder === 'asc' ? 1 : -1;

    const [assignments, total] = await Promise.all([
      InvestigationAssignment.find(filter)
        .sort({ [sortField]: sortOrder })
        .skip(skip)
        .limit(limit)
        .populate('officerId', 'name employeeId')
        .lean(),
      InvestigationAssignment.countDocuments(filter),
    ]);

    return {
      assignments,
      pagination: buildPaginationMeta(page, limit, total),
    };
  }

  /**
   * Verify that the authenticated user has access to this investigation.
   * Returns the assignment record.
   */
  async verifyAccess(req: AuthenticatedRequest, fastApiInvestigationId: string) {
    const user = req.user!;

    if (isSupervisorOrAdmin(req)) {
      // Supervisors/admins can access any investigation
      // Still try to find the assignment for context
      const assignment = await InvestigationAssignment.findOne({
        fastApiInvestigationId,
      }).lean();
      return assignment; // May be null — that's ok for admin
    }

    const assignment = await InvestigationAssignment.findOne({
      fastApiInvestigationId,
      officerId: user._id,
    }).lean();

    if (!assignment) {
      throw new AppError(
        403,
        'INVESTIGATION_NOT_ASSIGNED',
        'You do not have access to this investigation.'
      );
    }

    return assignment;
  }

  async getFullInvestigation(fastApiInvestigationId: string): Promise<FastApiFullInvestigation | null> {
    return FastApiDatabase.getInvestigationFull(fastApiInvestigationId);
  }

  async acceptInvestigation(req: AuthenticatedRequest, fastApiInvestigationId: string) {
    await this.verifyAccess(req, fastApiInvestigationId);

    const assignment = await InvestigationAssignment.findOneAndUpdate(
      {
        fastApiInvestigationId,
        officerId: req.user!._id,
        status: AssignmentStatus.ASSIGNED,
      },
      {
        status: AssignmentStatus.ACCEPTED,
        acceptedAt: new Date(),
      },
      { new: true }
    );

    if (!assignment) {
      throw new AppError(409, 'INVALID_STATE', 'Cannot accept this investigation in its current state.');
    }

    return assignment;
  }

  async startInvestigation(req: AuthenticatedRequest, fastApiInvestigationId: string) {
    await this.verifyAccess(req, fastApiInvestigationId);

    const assignment = await InvestigationAssignment.findOneAndUpdate(
      {
        fastApiInvestigationId,
        officerId: req.user!._id,
        status: { $in: [AssignmentStatus.ACCEPTED, AssignmentStatus.ASSIGNED] },
      },
      {
        status: AssignmentStatus.IN_PROGRESS,
        startedAt: new Date(),
      },
      { new: true }
    );

    if (!assignment) {
      throw new AppError(409, 'INVALID_STATE', 'Cannot start this investigation in its current state.');
    }

    return assignment;
  }

  async assignOfficer(
    fastApiInvestigationId: string,
    officerId: string,
    assignedById: string,
    priority = 'MEDIUM',
    notes?: string
  ) {
    const existing = await InvestigationAssignment.findOne({
      fastApiInvestigationId,
      officerId: new mongoose.Types.ObjectId(officerId),
      status: { $nin: [AssignmentStatus.CANCELLED, AssignmentStatus.COMPLETED] },
    });

    if (existing) {
      throw new AppError(409, 'ALREADY_ASSIGNED', 'Officer is already assigned to this investigation.');
    }

    const assignment = await InvestigationAssignment.create({
      fastApiInvestigationId,
      officerId: new mongoose.Types.ObjectId(officerId),
      assignedBy: new mongoose.Types.ObjectId(assignedById),
      status: AssignmentStatus.ASSIGNED,
      priority: priority.toUpperCase(),
      notes,
    });

    const officer = await User.findById(officerId).select('fcmToken name').lean();
    if (officer?.fcmToken) {
      await NotificationService.sendPushNotification(
        officer.fcmToken,
        'New Investigation Assigned',
        `Hello ${officer.name}, you have been assigned a new investigation.`,
        { investigationId: fastApiInvestigationId }
      );
    }

    return assignment;
  }

  async getMapData(fastApiInvestigationId: string) {
    const full = await FastApiDatabase.getInvestigationFull(fastApiInvestigationId);

    if (!full) {
      return {
        sourceRegion: null,
        sourceUncertainty: null,
        slickGeometry: null,
        vesselTracks: [],
        candidateVessels: [],
        evidenceLocations: [],
      };
    }

    const candidateVessels = (full.candidates || []).map((c) => ({
      rank: c.rank,
      vesselId: c.vessel.vessel_id,
      name: c.vessel.name,
      mmsi: c.vessel.mmsi,
      vesselType: c.vessel.vessel_type,
      attributionScore: c.attribution_score,
    }));

    const vesselTracks = (full.candidates || []).map((c) => ({
      vesselId: c.vessel.vessel_id,
      name: c.vessel.name,
      positions: c.vessel.positions || [],
    }));

    return {
      sourceRegion: full.reconstruction?.source_region || null,
      sourceUncertainty: full.reconstruction?.confidence
        ? (1 - full.reconstruction.confidence) * 10
        : null,
      slickGeometry: full.detection?.geometry || null,
      vesselTracks,
      candidateVessels,
      evidenceLocations: [],
    };
  }
}

export const investigationService = new InvestigationService();
