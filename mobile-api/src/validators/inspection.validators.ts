import { z } from 'zod';

export const createObservationSchema = z.object({
  type: z.enum([
    'VISIBLE_OIL', 'WATER_CONDITION', 'WEATHER', 'WIND', 'CURRENT',
    'SEA_STATE', 'VESSEL_SIGHTING', 'SHORELINE_CONTAMINATION', 'ODOR', 'DEBRIS', 'OTHER'
  ]),
  value: z.string().min(1, 'Value is required'),
  timestamp: z.string().datetime(),
  latitude: z.number().min(-90).max(90).optional(),
  longitude: z.number().min(-180).max(180).optional(),
  accuracy: z.number().optional(),
  notes: z.string().optional(),
  clientRequestId: z.string().optional(),
});

export const updateObservationSchema = createObservationSchema.partial();

export const arrivalLocationSchema = z.object({
  latitude: z.number().min(-90).max(90),
  longitude: z.number().min(-180).max(180),
  accuracy: z.number().optional(),
  altitude: z.number().optional(),
});

export const assignOfficerSchema = z.object({
  officerId: z.string().min(1),
  priority: z.enum(['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']).optional(),
  notes: z.string().optional(),
});

export const sosSchema = z.object({
  contactType: z.enum(['COAST_GUARD', 'LOCAL_AUTHORITY', 'EMERGENCY_CONTACT']),
  latitude: z.number().min(-90).max(90).optional(),
  longitude: z.number().min(-180).max(180).optional(),
  accuracy: z.number().optional(),
  fastApiInvestigationId: z.string().optional(),
  inspectionId: z.string().optional(),
  notes: z.string().optional(),
});
