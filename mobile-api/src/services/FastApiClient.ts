import axios, { AxiosInstance, AxiosError } from 'axios';
import { config } from '../config';
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

export interface FastApiTimelineEvent {
  timestamp: string;
  event: string;
}

class FastApiClient {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: config.FASTAPI_BASE_URL,
      timeout: 30000,
      headers: { 'Content-Type': 'application/json' },
    });

    this.client.interceptors.response.use(
      (response) => response,
      (error: AxiosError) => {
        logger.warn('FastAPI request failed', {
          url: error.config?.url,
          status: error.response?.status,
          message: error.message,
        });
        return Promise.reject(error);
      }
    );
  }

  async getInvestigation(id: string): Promise<FastApiInvestigation | null> {
    try {
      const { data } = await this.client.get<FastApiInvestigation>(
        `/api/v1/investigations/${id}`
      );
      return data;
    } catch (error) {
      if (axios.isAxiosError(error) && error.response?.status === 404) return null;
      throw error;
    }
  }

  async getInvestigationFull(id: string): Promise<FastApiFullInvestigation | null> {
    try {
      const { data } = await this.client.get<FastApiFullInvestigation>(
        `/api/v1/investigations/${id}/full`
      );
      return data;
    } catch (error) {
      if (axios.isAxiosError(error) && error.response?.status === 404) return null;
      logger.error('FastAPI getInvestigationFull error', { id, error });
      return null; // Degrade gracefully — field inspection can still proceed
    }
  }

  async getTimeline(id: string): Promise<FastApiTimelineEvent[]> {
    try {
      const { data } = await this.client.get<FastApiTimelineEvent[]>(
        `/api/v1/investigations/${id}/timeline`
      );
      return data;
    } catch (error) {
      logger.warn('FastAPI timeline unavailable', { id });
      return [];
    }
  }

  async listInvestigations(): Promise<FastApiInvestigation[]> {
    try {
      const { data } = await this.client.get<FastApiInvestigation[]>(
        '/api/v1/investigations/'
      );
      return Array.isArray(data) ? data : [];
    } catch (error) {
      logger.warn('FastAPI listInvestigations failed');
      return [];
    }
  }

  async healthCheck(): Promise<boolean> {
    try {
      await this.client.get('/health', { timeout: 3000 });
      return true;
    } catch {
      return false;
    }
  }
}

export const fastApiClient = new FastApiClient();
