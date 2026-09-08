import mongoose, { Document, Schema } from 'mongoose';

export const InspectionStatus = {
  NOT_STARTED: 'NOT_STARTED',
  IN_PROGRESS: 'IN_PROGRESS',
  DRAFT: 'DRAFT',
  SUBMITTED: 'SUBMITTED',
  SYNCED: 'SYNCED',
  REQUIRES_REVIEW: 'REQUIRES_REVIEW',
} as const;

export type InspectionStatus = (typeof InspectionStatus)[keyof typeof InspectionStatus];

export const InspectionFinding = {
  OIL_CONFIRMED: 'OIL_CONFIRMED',
  OIL_NOT_FOUND: 'OIL_NOT_FOUND',
  INCONCLUSIVE: 'INCONCLUSIVE',
  REQUIRES_FURTHER_INVESTIGATION: 'REQUIRES_FURTHER_INVESTIGATION',
} as const;

export type InspectionFinding = (typeof InspectionFinding)[keyof typeof InspectionFinding];

export interface IGpsLocation {
  latitude: number;
  longitude: number;
  accuracy?: number;
  altitude?: number;
  timestamp: Date;
}

export interface IFieldInspection extends Document {
  _id: mongoose.Types.ObjectId;
  fastApiInvestigationId: string;
  officerId: mongoose.Types.ObjectId;
  status: InspectionStatus;

  startedAt?: Date;
  completedAt?: Date;
  submittedAt?: Date;

  arrivalLocation?: IGpsLocation;

  // Structured field observations
  siteConditions?: {
    seaState?: string;       // CALM | MODERATE | ROUGH | VERY_ROUGH
    visibility?: string;     // GOOD | MODERATE | POOR
    weatherCondition?: string;
    windSpeed?: number;      // km/h
    windDirection?: string;
    currentSpeed?: number;   // knots
    currentDirection?: string;
    temperature?: number;    // Celsius
    humidity?: number;       // %
  };

  oilObservation?: {
    visibleOil: boolean;
    slickArea?: number;      // estimated square meters
    slickColor?: string;
    slickThickness?: string; // SHEEN | RAINBOW | DARK | THICK
    odorPresent?: boolean;
    odorDescription?: string;
    notes?: string;
  };

  environmentObservation?: {
    shorelineAffected: boolean;
    marineLifeAffected: boolean;
    wildlifeObservations?: string;
    debrisPresent?: boolean;
    notes?: string;
  };

  vesselObservations?: Array<{
    vesselName?: string;
    mmsi?: string;
    imoNumber?: string;
    flagState?: string;
    vesselType?: string;
    heading?: number;
    speed?: number;
    distance?: number; // nautical miles
    notes?: string;
    observedAt: Date;
    location?: IGpsLocation;
  }>;

  notes?: string;
  finding?: InspectionFinding;

  // Idempotency — client-provided unique key
  clientRequestId?: string;

  createdAt: Date;
  updatedAt: Date;
}

const gpsLocationSchema = new Schema<IGpsLocation>(
  {
    latitude: { type: Number, required: true },
    longitude: { type: Number, required: true },
    accuracy: { type: Number },
    altitude: { type: Number },
    timestamp: { type: Date, required: true },
  },
  { _id: false }
);

const fieldInspectionSchema = new Schema<IFieldInspection>(
  {
    fastApiInvestigationId: { type: String, required: true },
    officerId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    status: {
      type: String,
      enum: Object.values(InspectionStatus),
      default: InspectionStatus.NOT_STARTED,
    },

    startedAt: { type: Date },
    completedAt: { type: Date },
    submittedAt: { type: Date },

    arrivalLocation: { type: gpsLocationSchema },

    siteConditions: {
      seaState: { type: String },
      visibility: { type: String },
      weatherCondition: { type: String },
      windSpeed: { type: Number },
      windDirection: { type: String },
      currentSpeed: { type: Number },
      currentDirection: { type: String },
      temperature: { type: Number },
      humidity: { type: Number },
    },

    oilObservation: {
      visibleOil: { type: Boolean },
      slickArea: { type: Number },
      slickColor: { type: String },
      slickThickness: { type: String },
      odorPresent: { type: Boolean },
      odorDescription: { type: String },
      notes: { type: String },
    },

    environmentObservation: {
      shorelineAffected: { type: Boolean },
      marineLifeAffected: { type: Boolean },
      wildlifeObservations: { type: String },
      debrisPresent: { type: Boolean },
      notes: { type: String },
    },

    vesselObservations: [
      {
        vesselName: { type: String },
        mmsi: { type: String },
        imoNumber: { type: String },
        flagState: { type: String },
        vesselType: { type: String },
        heading: { type: Number },
        speed: { type: Number },
        distance: { type: Number },
        notes: { type: String },
        observedAt: { type: Date, required: true },
        location: { type: gpsLocationSchema },
      },
    ],

    notes: { type: String },
    finding: {
      type: String,
      enum: Object.values(InspectionFinding),
    },

    clientRequestId: { type: String, unique: true, sparse: true },
  },
  { timestamps: true, versionKey: false }
);

fieldInspectionSchema.index({ fastApiInvestigationId: 1, officerId: 1 });
fieldInspectionSchema.index({ officerId: 1, status: 1 });
fieldInspectionSchema.index({ clientRequestId: 1 }, { unique: true, sparse: true });

// Geospatial index on arrival location
fieldInspectionSchema.index({
  'arrivalLocation.latitude': 1,
  'arrivalLocation.longitude': 1,
});

export const FieldInspection = mongoose.model<IFieldInspection>(
  'FieldInspection',
  fieldInspectionSchema,
  'field_inspections'
);
