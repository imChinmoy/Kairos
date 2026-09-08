import mongoose, { Document, Schema } from 'mongoose';

export const EvidenceType = {
  PHOTO: 'PHOTO',
  VIDEO: 'VIDEO',
  AUDIO: 'AUDIO',
  DOCUMENT: 'DOCUMENT',
  OTHER: 'OTHER',
} as const;

export type EvidenceType = (typeof EvidenceType)[keyof typeof EvidenceType];

export const EvidenceSyncStatus = {
  LOCAL: 'LOCAL',
  UPLOADING: 'UPLOADING',
  SYNCED: 'SYNCED',
  FAILED: 'FAILED',
  HASH_MISMATCH: 'HASH_MISMATCH',
} as const;

export type EvidenceSyncStatus = (typeof EvidenceSyncStatus)[keyof typeof EvidenceSyncStatus];

export interface IEvidence extends Document {
  _id: mongoose.Types.ObjectId;
  fastApiInvestigationId: string;
  inspectionId: mongoose.Types.ObjectId;
  officerId: mongoose.Types.ObjectId;

  type: EvidenceType;
  fileName: string;
  mimeType: string;
  fileSize: number; // bytes

  storagePath: string;
  remoteUrl?: string;

  // SHA-256 chain of custody
  clientSha256: string;  // hash provided by Flutter before upload
  serverSha256?: string; // hash computed by server after receiving file
  hashVerified: boolean;

  capturedAt: Date;

  location?: {
    latitude: number;
    longitude: number;
    accuracy?: number;
  };

  metadata?: Record<string, unknown>;

  syncStatus: EvidenceSyncStatus;
  clientRequestId?: string;

  createdAt: Date;
  updatedAt: Date;
}

const evidenceSchema = new Schema<IEvidence>(
  {
    fastApiInvestigationId: { type: String, required: true },
    inspectionId: { type: Schema.Types.ObjectId, ref: 'FieldInspection', required: true },
    officerId: { type: Schema.Types.ObjectId, ref: 'User', required: true },

    type: {
      type: String,
      enum: Object.values(EvidenceType),
      required: true,
    },

    fileName: { type: String, required: true },
    mimeType: { type: String, required: true },
    fileSize: { type: Number, required: true },

    storagePath: { type: String, required: true },
    remoteUrl: { type: String },

    clientSha256: { type: String, required: true },
    serverSha256: { type: String },
    hashVerified: { type: Boolean, default: false },

    capturedAt: { type: Date, required: true },

    location: {
      latitude: { type: Number },
      longitude: { type: Number },
      accuracy: { type: Number },
    },

    metadata: { type: Schema.Types.Mixed },

    syncStatus: {
      type: String,
      enum: Object.values(EvidenceSyncStatus),
      default: EvidenceSyncStatus.LOCAL,
    },

    clientRequestId: { type: String },
  },
  { timestamps: true, versionKey: false }
);

evidenceSchema.index({ fastApiInvestigationId: 1 });
evidenceSchema.index({ inspectionId: 1 });
evidenceSchema.index({ officerId: 1 });
evidenceSchema.index({ clientRequestId: 1 }, { unique: true, sparse: true });
evidenceSchema.index({ syncStatus: 1 });

// 2dsphere for geospatial queries on evidence location
evidenceSchema.index({ location: '2dsphere' }, { sparse: true });

export const Evidence = mongoose.model<IEvidence>('Evidence', evidenceSchema, 'evidence');
