import mongoose, { Document, Schema } from 'mongoose';

export interface IRefreshToken extends Document {
  userId: mongoose.Types.ObjectId;
  token: string; // stored as SHA-256 hash
  expiresAt: Date;
  isRevoked: boolean;
  createdAt: Date;
}

const refreshTokenSchema = new Schema<IRefreshToken>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    token: { type: String, required: true, unique: true },
    expiresAt: { type: Date, required: true },
    isRevoked: { type: Boolean, default: false },
  },
  { timestamps: { createdAt: true, updatedAt: false }, versionKey: false }
);

refreshTokenSchema.index({ userId: 1 });
refreshTokenSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 }); // TTL index

export const RefreshToken = mongoose.model<IRefreshToken>(
  'RefreshToken',
  refreshTokenSchema,
  'refresh_tokens'
);
