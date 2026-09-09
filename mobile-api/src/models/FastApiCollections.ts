import mongoose from 'mongoose';
import { logger } from '../utils/logger';

export interface FastApiInvestigation {
  _id: string;
  status: string;
  observation_ids: string[];
  candidate_ids: string[];
  created_at: string;
  updated_at: string;
}

export interface FastApiFullInvestigation {
  investigation: FastApiInvestigation;
  sar_image_url?: string | null;
  observation?: {
    _id: string;
    timestamp: string;
    sensor: string;
    resolution_m?: number;
    image_reference?: string;
  };
  detection?: {
    detected: boolean;
    confidence: number;
    area_km2: number;
    geometry: GeoJSON.Geometry | null;
    model?: { name: string; version: string };
  };
  reconstruction?: {
    release_window: { start_time: string; end_time: string };
    source_region: GeoJSON.Geometry | null;
    confidence: number;
  };
  environment?: {
    wind_speed_kn: number;
    current_speed_kn: number;
    wind_direction?: string;
    current_direction?: string;
  };
  candidates?: Array<{
    rank: number;
    vessel: {
      vessel_id: string;
      name: string;
      mmsi: string;
      vessel_type: string;
      positions?: Array<{ lat: number; lon: number; timestamp: string }>;
    };
    attribution_score: number;
    evidence: {
      spatial: number;
      temporal: number;
      drift: number;
      trajectory: number;
      ais_quality: number;
    };
    explanations: string[];
  }>;
}

export class FastApiDatabase {
  
  static async getInvestigationFull(id: string): Promise<FastApiFullInvestigation | null> {
    try {
      const db = mongoose.connection.db;
      if (!db) {
        logger.error('Mongoose connection not established');
        return null;
      }

      const investigationObjId = new mongoose.Types.ObjectId(id);

      // Fetch investigation
      const investigation = await db.collection('investigations').findOne({ _id: investigationObjId });
      
      if (!investigation) {
        return null;
      }

      // Fetch related documents based on the investigation data
      // FastAPI usually stores observations, detections etc referenced by investigation_id as strings
      const obsPromise = db.collection('observations').findOne({ investigation_id: id });
      const detPromise = db.collection('detections').findOne({ investigation_id: id });
      const recPromise = db.collection('reconstructions').findOne({ investigation_id: id });
      const envPromise = db.collection('environments').findOne({ investigation_id: id });
      
      // Candidates are usually an array of ObjectIds in `candidate_ids`
      let candPromise: Promise<any[]> = Promise.resolve([]);
      if (investigation.candidate_ids && Array.isArray(investigation.candidate_ids) && investigation.candidate_ids.length > 0) {
        candPromise = db.collection('candidates')
          .find({ _id: { $in: investigation.candidate_ids } })
          .sort({ rank: 1 })
          .toArray();
      } else {
        // Alternatively, they might just be queried by investigation_id
        candPromise = db.collection('candidates')
          .find({ investigation_id: id })
          .sort({ rank: 1 })
          .toArray();
      }

      const [observation, detection, reconstruction, environment, candidates] = await Promise.all([
        obsPromise, detPromise, recPromise, envPromise, candPromise
      ]);

      // Format response to match exactly what the frontend/controller expects
      return {
        investigation: {
          _id: investigation._id.toString(),
          status: investigation.status,
          observation_ids: (investigation.observation_ids || []).map((oid: any) => oid.toString()),
          candidate_ids: (investigation.candidate_ids || []).map((cid: any) => cid.toString()),
          created_at: investigation.created_at || investigation.createdAt,
          updated_at: investigation.updated_at || investigation.updatedAt,
        },
        observation: observation ? {
          _id: observation._id.toString(),
          timestamp: observation.timestamp,
          sensor: observation.sensor,
          resolution_m: observation.resolution_m,
          image_reference: observation.image_reference,
        } : undefined,
        sar_image_url: observation?.image_reference || null,
        detection: detection ? {
          detected: detection.detected,
          confidence: detection.confidence,
          area_km2: detection.area_km2,
          geometry: detection.geometry,
          model: detection.model,
        } : undefined,
        reconstruction: reconstruction ? {
          release_window: reconstruction.release_window,
          source_region: reconstruction.source_region,
          confidence: reconstruction.confidence,
        } : undefined,
        environment: environment ? {
          wind_speed_kn: environment.wind_speed_kn,
          current_speed_kn: environment.current_speed_kn,
          wind_direction: environment.wind_direction,
          current_direction: environment.current_direction,
        } : undefined,
        candidates: candidates.map(c => ({
          rank: c.rank,
          vessel: c.vessel,
          attribution_score: c.attribution_score,
          evidence: c.evidence,
          explanations: c.explanations || [],
        })),
      };
    } catch (error) {
      logger.error('Error fetching investigation directly from DB', { id, error });
      return null;
    }
  }

  static async getInvestigation(id: string): Promise<FastApiInvestigation | null> {
    try {
      const db = mongoose.connection.db;
      if (!db) return null;
      const investigation = await db.collection('investigations').findOne({ _id: new mongoose.Types.ObjectId(id) });
      if (!investigation) return null;
      return {
        _id: investigation._id.toString(),
        status: investigation.status,
        observation_ids: (investigation.observation_ids || []).map((oid: any) => oid.toString()),
        candidate_ids: (investigation.candidate_ids || []).map((cid: any) => cid.toString()),
        created_at: investigation.created_at || investigation.createdAt,
        updated_at: investigation.updated_at || investigation.updatedAt,
      };
    } catch (error) {
      return null;
    }
  }
}
