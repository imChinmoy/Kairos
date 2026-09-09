import mongoose, { Document, Schema } from 'mongoose';

export const UserRole = {
  OFFICER: 'OFFICER',
  SUPERVISOR: 'SUPERVISOR',
  ADMIN: 'ADMIN',
} as const;

export type UserRole = (typeof UserRole)[keyof typeof UserRole];

export interface IUser extends Document {
  _id: mongoose.Types.ObjectId;
  employeeId: string;
  name: string;
  email: string;
  phone?: string;
  passwordHash: string;
  role: UserRole;
  department?: string;
  designation?: string;
  isActive: boolean;
  fcmToken?: string;
  lastLoginAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

const userSchema = new Schema<IUser>(
  {
    employeeId: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      uppercase: true,
    },
    name: { type: String, required: true, trim: true },
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    phone: { type: String, trim: true },
    passwordHash: { type: String, required: true, select: false },
    role: {
      type: String,
      enum: Object.values(UserRole),
      default: UserRole.OFFICER,
    },
    department: { type: String, trim: true },
    designation: { type: String, trim: true },
    isActive: { type: Boolean, default: true },
    fcmToken: { type: String, trim: true },
    lastLoginAt: { type: Date },
  },
  {
    timestamps: true,
    versionKey: false,
  }
);

// Indexes
userSchema.index({ email: 1 }, { unique: true });
userSchema.index({ employeeId: 1 }, { unique: true });
userSchema.index({ role: 1 });
userSchema.index({ isActive: 1 });

// Never expose password hash in JSON output
userSchema.set('toJSON', {
  transform: (_doc, ret: any) => {
    delete ret.passwordHash;
    return ret;
  },
});

export const User = mongoose.model<IUser>('User', userSchema, 'users');
