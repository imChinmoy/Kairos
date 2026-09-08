import mongoose, { Document, Schema } from 'mongoose';

export interface ISosEvent extends Document {
  _id: mongoose.Types.ObjectId;
  officerId: mongoose.Types.ObjectId;
  fastApiInvestigationId?: string;
  inspectionId?: mongoose.Types.ObjectId;

  triggeredAt: Date;

  location?: {
    latitude: number;
    longitude: number;
    accuracy?: number;
  };

  contactType: 'COAST_GUARD' | 'LOCAL_AUTHORITY' | 'EMERGENCY_CONTACT';
  acknowledged: boolean;
  acknowledgedAt?: Date;
  acknowledgedBy?: mongoose.Types.ObjectId;

  notes?: string;
  createdAt: Date;
}

const sosEventSchema = new Schema<ISosEvent>(
  {
    officerId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    fastApiInvestigationId: { type: String },
    inspectionId: { type: Schema.Types.ObjectId, ref: 'FieldInspection' },

    triggeredAt: { type: Date, required: true, default: Date.now },

    location: {
      latitude: { type: Number },
      longitude: { type: Number },
      accuracy: { type: Number },
    },

    contactType: {
      type: String,
      enum: ['COAST_GUARD', 'LOCAL_AUTHORITY', 'EMERGENCY_CONTACT'],
      required: true,
    },
    acknowledged: { type: Boolean, default: false },
    acknowledgedAt: { type: Date },
    acknowledgedBy: { type: Schema.Types.ObjectId, ref: 'User' },
    notes: { type: String },
  },
  { timestamps: { createdAt: true, updatedAt: false }, versionKey: false }
);

sosEventSchema.index({ officerId: 1, triggeredAt: -1 });
sosEventSchema.index({ acknowledged: 1 });

export const SosEvent = mongoose.model<ISosEvent>('SosEvent', sosEventSchema, 'sos_events');
