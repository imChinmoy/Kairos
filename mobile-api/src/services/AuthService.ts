import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { config } from '../config';
import { User, IUser } from '../models/User';
import { RefreshToken } from '../models/RefreshToken';
import { AppError } from '../middleware/errorHandler';

export interface LoginResult {
  user: IUser;
  accessToken: string;
  refreshToken: string;
}

function generateAccessToken(user: IUser): string {
  return jwt.sign(
    {
      sub: user._id.toString(),
      role: user.role,
      employeeId: user.employeeId,
    },
    config.JWT_SECRET,
    { expiresIn: config.JWT_EXPIRES_IN as jwt.SignOptions['expiresIn'] }
  );
}

function generateRefreshToken(): string {
  return crypto.randomBytes(64).toString('hex');
}

export class AuthService {
  async login(identifier: string, password: string): Promise<LoginResult> {
    // Support both email and employeeId
    const query = identifier.includes('@')
      ? { email: identifier.toLowerCase() }
      : { employeeId: identifier.toUpperCase() };

    const user = await User.findOne(query).select('+passwordHash +isActive').lean<IUser>();

    if (!user) {
      // Constant-time comparison to avoid user enumeration timing attacks
      await bcrypt.compare(password, '$2a$12$dummyhashfortimingatack00000000000000000000');
      throw new AppError(401, 'INVALID_CREDENTIALS', 'Invalid credentials. Please try again.');
    }

    if (!user.isActive) {
      throw new AppError(401, 'ACCOUNT_DISABLED', 'Your account has been disabled.');
    }

    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);

    if (!isPasswordValid) {
      throw new AppError(401, 'INVALID_CREDENTIALS', 'Invalid credentials. Please try again.');
    }

    // Generate tokens
    const accessToken = generateAccessToken(user);
    const rawRefreshToken = generateRefreshToken();

    // Hash the refresh token before storing
    const tokenHash = crypto.createHash('sha256').update(rawRefreshToken).digest('hex');

    const expiryMs = 7 * 24 * 60 * 60 * 1000; // 7 days
    await RefreshToken.create({
      userId: user._id,
      token: tokenHash,
      expiresAt: new Date(Date.now() + expiryMs),
    });

    // Update last login
    await User.findByIdAndUpdate(user._id, { lastLoginAt: new Date() });

    return {
      user,
      accessToken,
      refreshToken: rawRefreshToken,
    };
  }

  async refresh(rawRefreshToken: string): Promise<{ accessToken: string; refreshToken: string }> {
    const tokenHash = crypto.createHash('sha256').update(rawRefreshToken).digest('hex');

    const storedToken = await RefreshToken.findOne({
      token: tokenHash,
      isRevoked: false,
      expiresAt: { $gt: new Date() },
    });

    if (!storedToken) {
      throw new AppError(401, 'INVALID_REFRESH_TOKEN', 'Invalid or expired refresh token.');
    }

    const user = await User.findById(storedToken.userId).lean<IUser>();
    if (!user || !user.isActive) {
      throw new AppError(401, 'USER_INACTIVE', 'User account is inactive.');
    }

    // Rotate refresh token (revoke old, issue new)
    storedToken.isRevoked = true;
    await storedToken.save();

    const newAccessToken = generateAccessToken(user);
    const newRawRefreshToken = generateRefreshToken();
    const newTokenHash = crypto.createHash('sha256').update(newRawRefreshToken).digest('hex');

    const expiryMs = 7 * 24 * 60 * 60 * 1000;
    await RefreshToken.create({
      userId: user._id,
      token: newTokenHash,
      expiresAt: new Date(Date.now() + expiryMs),
    });

    return { accessToken: newAccessToken, refreshToken: newRawRefreshToken };
  }

  async logout(rawRefreshToken: string): Promise<void> {
    const tokenHash = crypto.createHash('sha256').update(rawRefreshToken).digest('hex');
    await RefreshToken.updateOne({ token: tokenHash }, { isRevoked: true });
  }

  async hashPassword(plaintext: string): Promise<string> {
    return bcrypt.hash(plaintext, 12);
  }
}

export const authService = new AuthService();
