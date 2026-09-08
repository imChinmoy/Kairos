import mongoose, { Document, Schema } from 'mongoose';

export const AssignmentStatus = {
  ASSIGNED: 'ASSIGNED',
  ACCEPTED: 'ACCEPTED',
  IN_PROGRESS: 'IN_PROGRESS',
  COMPLETED: 'COMPLETED',
  CANCELLED: 'CANCELLED',
} as const;

export type AssignmentStatus = (typeof AssignmentStatus)[keyof typeof AssignmentStatus];

export interface IInvestigationAssignment extends Document {
  _id: mongoose.Types.ObjectId;
  // References the FastAPI investigation _id (stored as string to avoid coupling)
  fastApiInvestigationId: string;
  officerId: mongoose.Types.ObjectId;
  assignedBy: mongoose.Types.ObjectId;
  status: AssignmentStatus;
  priority: string;
  notes?: string;
  assignedAt: Date;
  acceptedAt?: Date;
  startedAt?: Date;
  completedAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

const investigationAssignmentSchema = new Schema<IInvestigationAssignment>(
  {
    fastApiInvestigationId: { type: String, required: true },
    officerId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    assignedBy: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    status: {
      type: String,
      enum: Object.values(AssignmentStatus),
      default: AssignmentStatus.ASSIGNED,
    },
    priority: { type: String, default: 'MEDIUM' },
    notes: { type: String },
    assignedAt: { type: Date, default: Date.now },
    acceptedAt: { type: Date },
    startedAt: { type: Date },
    completedAt: { type: Date },
  },
  { timestamps: true, versionKey: false }
);

investigationAssignmentSchema.index({ officerId: 1, status: 1 });
investigationAssignmentSchema.index({ fastApiInvestigationId: 1, officerId: 1 });
investigationAssignmentSchema.index({ fastApiInvestigationId: 1 });

export const InvestigationAssignment = mongoose.model<IInvestigationAssignment>(
  'InvestigationAssignment',
  investigationAssignmentSchema,
  'investigation_assignments'
);
