import { Response } from 'express';
import { AuthenticatedRequest } from '../middleware/authenticate';
import { investigationService } from '../services/InvestigationService';
import { FastApiDatabase } from '../models/FastApiCollections';
import { sendSuccess, sendPaginated, sendError } from '../utils/apiResponse';
import { createAuditLog } from '../services/AuditService';
import { AuditAction } from '../models/AuditLog';
import { FieldInspection } from '../models/FieldInspection';
import { Evidence } from '../models/Evidence';
import { InvestigationAssignment } from '../models/InvestigationAssignment';
import { assignOfficerSchema } from '../validators/inspection.validators';
import { UserRole } from '../models/User';
import { z } from 'zod';

function calculateCentroid(geometry: any): { latitude: number; longitude: number } | null {
  if (!geometry || geometry.type !== 'Polygon' || !Array.isArray(geometry.coordinates)) return null;
  const ring = geometry.coordinates[0];
  if (!Array.isArray(ring) || ring.length === 0) return null;
  
  let sumLat = 0;
  let sumLng = 0;
  for (const pt of ring) {
    sumLng += pt[0];
    sumLat += pt[1];
  }
  return {
    latitude: sumLat / ring.length,
    longitude: sumLng / ring.length,
  };
}

export async function listInvestigations(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { assignments, pagination } = await investigationService.listForUser(req, req.query as Record<string, string>);

  // Enrich with FastAPI data where available
  // For performance in a list view, we return the assignment + basic FastAPI status
  const enriched = await Promise.all(
    assignments.map(async (a) => {
      const fastApiData = await FastApiDatabase.getInvestigation(a.fastApiInvestigationId).catch(() => null);
      return {
        id: a.fastApiInvestigationId,
        assignmentId: a._id,
        assignmentStatus: a.status,
        priority: a.priority,
        assignedAt: a.assignedAt,
        fastApiStatus: fastApiData?.status || null,
      };
    })
  );

  sendPaginated(res, enriched, pagination);
}

export async function getInvestigation(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { id } = req.params;

  await investigationService.verifyAccess(req, id);

  const full = await investigationService.getFullInvestigation(id);

  if (!full) {
    // FastAPI offline — return what we know from our assignment
    const assignment = await InvestigationAssignment.findOne({ fastApiInvestigationId: id }).lean();
    sendSuccess(res, {
      id,
      title: 'Investigation Data Unavailable',
      status: assignment?.status || 'UNKNOWN',
      sourceRegion: null,
      fastApiUnavailable: true,
    });
    return;
  }

  await createAuditLog({
    userId: req.user!._id,
    action: AuditAction.VIEW_INVESTIGATION,
    entityType: 'Investigation',
    entityId: id,
    ipAddress: req.ip,
  });

  // Adapt FastAPI response to mobile-friendly format
  const investigation = full.investigation;
  const obs = full.observation;
  const detection = full.detection;
  const reconstruction = full.reconstruction;
  const env = full.environment;
  const candidates = full.candidates || [];

  const inspection = await FieldInspection.findOne({
    fastApiInvestigationId: id,
    officerId: req.user!._id,
  }).lean();

  sendSuccess(res, {
    id,
    fastApiStatus: investigation.status,
    investigationDetails: investigation,
    observation: obs ? {
      ...obs,
    } : null,
    detection: detection ? {
      ...detection,
      areaKm2: detection.area_km2,
    } : null,
    reconstruction: reconstruction ? {
      ...reconstruction,
    } : null,
    environment: env ? {
      ...env,
    } : null,
    sourceRegion: reconstruction?.source_region || null,
    targetLocation: calculateCentroid(reconstruction?.source_region),
    releaseTimeWindow: reconstruction
      ? { start: reconstruction.release_window.start_time, end: reconstruction.release_window.end_time }
      : null,
    sourceUncertaintyKm: reconstruction
      ? parseFloat(((1 - reconstruction.confidence) * 10).toFixed(1))
      : null,
    modelConditions: env ? {
      windSpeedKn: env.wind_speed_kn,
      windDirection: env.wind_direction,
      currentSpeedKn: env.current_speed_kn,
      currentDirection: env.current_direction,
    } : null,
    candidateVessels: candidates.map((c) => ({
      ...c,
      rank: c.rank,
      vesselId: c.vessel.vessel_id,
      name: c.vessel.name,
      mmsi: c.vessel.mmsi,
      vesselType: c.vessel.vessel_type,
      attributionScore: c.attribution_score,
      compatibility: c.attribution_score >= 0.8 ? 'HIGH' : c.attribution_score >= 0.5 ? 'MEDIUM' : 'LOW',
      evidence: {
        spatial: c.evidence.spatial,
        temporal: c.evidence.temporal,
        drift: c.evidence.drift,
        trajectory: c.evidence.trajectory,
        aisQuality: c.evidence.ais_quality,
      },
      explanations: c.explanations,
    })),
    fieldInspection: inspection
      ? { id: inspection._id, status: inspection.status, startedAt: inspection.startedAt }
      : { status: 'NOT_STARTED' },
  });
}

export async function acceptInvestigation(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { id } = req.params;
  const assignment = await investigationService.acceptInvestigation(req, id);

  await createAuditLog({
    userId: req.user!._id,
    action: AuditAction.ACCEPT_INVESTIGATION,
    entityType: 'Investigation',
    entityId: id,
  });

  sendSuccess(res, assignment, 200, 'Investigation accepted.');
}

export async function startInvestigation(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { id } = req.params;
  const assignment = await investigationService.startInvestigation(req, id);
  sendSuccess(res, assignment, 200, 'Investigation started.');
}

export async function getMapData(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { id } = req.params;
  await investigationService.verifyAccess(req, id);

  // Add evidence locations from our DB
  const evidenceList = await Evidence.find({ fastApiInvestigationId: id, 'location.latitude': { $exists: true } })
    .select('location capturedAt type')
    .lean();

  const mapData = await investigationService.getMapData(id);
  (mapData as any).evidenceLocations = evidenceList
    .filter((e) => e.location?.latitude && e.location?.longitude)
    .map((e) => ({
      type: e.type,
      latitude: e.location!.latitude as number,
      longitude: e.location!.longitude as number,
      capturedAt: e.capturedAt,
    }));

  sendSuccess(res, mapData);
}

export async function getAssignments(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { id } = req.params;
  await investigationService.verifyAccess(req, id);

  const assignments = await InvestigationAssignment.find({ fastApiInvestigationId: id })
    .populate('officerId', 'name employeeId designation')
    .populate('assignedBy', 'name employeeId')
    .lean();

  sendSuccess(res, assignments);
}

export async function assignOfficer(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { id } = req.params;
  const body = assignOfficerSchema.parse(req.body);

  const assignment = await investigationService.assignOfficer(
    id,
    body.officerId,
    req.user!._id.toString(),
    body.priority,
    body.notes
  );

  await createAuditLog({
    userId: req.user!._id,
    action: AuditAction.ASSIGN_OFFICER,
    entityType: 'Investigation',
    entityId: id,
    metadata: { assignedOfficerId: body.officerId },
  });

  sendSuccess(res, assignment, 201, 'Officer assigned.');
}

export async function revokeAssignment(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { id, officerId } = req.params;

  const assignment = await InvestigationAssignment.findOneAndUpdate(
    { fastApiInvestigationId: id, officerId },
    { status: 'CANCELLED' },
    { new: true }
  );

  if (!assignment) {
    sendError(res, 404, 'ASSIGNMENT_NOT_FOUND', 'Assignment not found.');
    return;
  }

  await createAuditLog({
    userId: req.user!._id,
    action: AuditAction.REVOKE_ASSIGNMENT,
    entityType: 'Investigation',
    entityId: id,
    metadata: { revokedOfficerId: officerId },
  });

  sendSuccess(res, assignment, 200, 'Assignment revoked.');
}
