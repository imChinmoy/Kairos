import mongoose, { Document, Schema } from 'mongoose';

export const AuditAction = {
  LOGIN: 'LOGIN',
  LOGOUT: 'LOGOUT',
  LOGIN_FAILED: 'LOGIN_FAILED',
  VIEW_INVESTIGATION: 'VIEW_INVESTIGATION',
  ACCEPT_INVESTIGATION: 'ACCEPT_INVESTIGATION',
  START_INSPECTION: 'START_INSPECTION',
  UPDATE_INSPECTION: 'UPDATE_INSPECTION',
  RECORD_ARRIVAL: 'RECORD_ARRIVAL',
  CAPTURE_EVIDENCE: 'CAPTURE_EVIDENCE',
  DELETE_EVIDENCE: 'DELETE_EVIDENCE',
  ADD_OBSERVATION: 'ADD_OBSERVATION',
  SUBMIT_INSPECTION: 'SUBMIT_INSPECTION',
  SOS_TRIGGERED: 'SOS_TRIGGERED',
  SYNC: 'SYNC',
  ASSIGN_OFFICER: 'ASSIGN_OFFICER',
  REVOKE_ASSIGNMENT: 'REVOKE_ASSIGNMENT',
} as const;

export type AuditAction = (typeof AuditAction)[keyof typeof AuditAction];

export interface IAuditLog extends Document {
  _id: mongoose.Types.ObjectId;
  userId?: mongoose.Types.ObjectId;
  action: AuditAction;
  entityType?: string;
  entityId?: string;
  timestamp: Date;
  ipAddress?: string;
  userAgent?: string;
  metadata?: Record<string, unknown>;
}

const auditLogSchema = new Schema<IAuditLog>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User' },
    action: { type: String, enum: Object.values(AuditAction), required: true },
    entityType: { type: String },
    entityId: { type: String },
    timestamp: { type: Date, default: Date.now },
    ipAddress: { type: String },
    userAgent: { type: String },
    metadata: { type: Schema.Types.Mixed },
  },
  { versionKey: false }
);

auditLogSchema.index({ userId: 1, timestamp: -1 });
auditLogSchema.index({ action: 1, timestamp: -1 });
auditLogSchema.index({ entityId: 1 });

export const AuditLog = mongoose.model<IAuditLog>('AuditLog', auditLogSchema, 'audit_logs');
