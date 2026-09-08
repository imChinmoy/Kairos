import mongoose, { Document, Schema } from 'mongoose';

export const ObservationType = {
  VISIBLE_OIL: 'VISIBLE_OIL',
  WATER_CONDITION: 'WATER_CONDITION',
  WEATHER: 'WEATHER',
  WIND: 'WIND',
  CURRENT: 'CURRENT',
  SEA_STATE: 'SEA_STATE',
  VESSEL_SIGHTING: 'VESSEL_SIGHTING',
  SHORELINE_CONTAMINATION: 'SHORELINE_CONTAMINATION',
  ODOR: 'ODOR',
  DEBRIS: 'DEBRIS',
  OTHER: 'OTHER',
} as const;

export type ObservationType = (typeof ObservationType)[keyof typeof ObservationType];

export interface IFieldObservation extends Document {
  _id: mongoose.Types.ObjectId;
  fastApiInvestigationId: string;
  inspectionId: mongoose.Types.ObjectId;
  officerId: mongoose.Types.ObjectId;

  type: ObservationType;
  value: string;
  timestamp: Date;

  latitude?: number;
  longitude?: number;
  accuracy?: number;

  notes?: string;
  clientRequestId?: string;

  createdAt: Date;
  updatedAt: Date;
}

const fieldObservationSchema = new Schema<IFieldObservation>(
  {
    fastApiInvestigationId: { type: String, required: true },
    inspectionId: { type: Schema.Types.ObjectId, ref: 'FieldInspection', required: true },
    officerId: { type: Schema.Types.ObjectId, ref: 'User', required: true },

    type: {
      type: String,
      enum: Object.values(ObservationType),
      required: true,
    },
    value: { type: String, required: true },
    timestamp: { type: Date, required: true },

    latitude: { type: Number },
    longitude: { type: Number },
    accuracy: { type: Number },

    notes: { type: String },
    clientRequestId: { type: String, unique: true, sparse: true },
  },
  { timestamps: true, versionKey: false }
);

fieldObservationSchema.index({ inspectionId: 1 });
fieldObservationSchema.index({ fastApiInvestigationId: 1 });
fieldObservationSchema.index({ officerId: 1 });
fieldObservationSchema.index({ clientRequestId: 1 }, { unique: true, sparse: true });

export const FieldObservation = mongoose.model<IFieldObservation>(
  'FieldObservation',
  fieldObservationSchema,
  'field_observations'
);
