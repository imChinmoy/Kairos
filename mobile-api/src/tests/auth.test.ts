import request from 'supertest';
import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';
import { createApp } from '../app';
import { connectDatabase, disconnectDatabase } from '../config/database';
import { User } from '../models/User';

const app = createApp();

beforeAll(async () => {
  await connectDatabase();
  await User.deleteMany({ email: /@test\.kairos$/ });
});

afterAll(async () => {
  await User.deleteMany({ email: /@test\.kairos$/ });
  await disconnectDatabase();
});

describe('POST /api/v1/auth/login', () => {
  let testUserId: string;

  beforeAll(async () => {
    const hash = await bcrypt.hash('Test@1234', 12);
    const user = await User.create({
      employeeId: 'TEST-001',
      name: 'Test Officer',
      email: 'test.officer@test.kairos',
      passwordHash: hash,
      role: 'OFFICER',
      isActive: true,
    });
    testUserId = user._id.toString();
  });

  afterAll(async () => {
    await User.deleteOne({ _id: testUserId });
  });

  it('should login with valid employee ID and password', async () => {
    const res = await request(app)
      .post('/api/v1/auth/login')
      .send({ identifier: 'TEST-001', password: 'Test@1234' });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.accessToken).toBeDefined();
    expect(res.body.data.refreshToken).toBeDefined();
    expect(res.body.data.user.passwordHash).toBeUndefined(); // Must not leak hash
    expect(res.body.data.user.employeeId).toBe('TEST-001');
  });

  it('should login with valid email', async () => {
    const res = await request(app)
      .post('/api/v1/auth/login')
      .send({ identifier: 'test.officer@test.kairos', password: 'Test@1234' });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
  });

  it('should reject invalid password', async () => {
    const res = await request(app)
      .post('/api/v1/auth/login')
      .send({ identifier: 'TEST-001', password: 'WrongPassword' });

    expect(res.status).toBe(401);
    expect(res.body.success).toBe(false);
    expect(res.body.error.code).toBe('INVALID_CREDENTIALS');
  });

  it('should reject non-existent user', async () => {
    const res = await request(app)
      .post('/api/v1/auth/login')
      .send({ identifier: 'NONEXISTENT-999', password: 'Test@1234' });

    expect(res.status).toBe(401);
    expect(res.body.success).toBe(false);
  });

  it('should require identifier and password fields', async () => {
    const res = await request(app)
      .post('/api/v1/auth/login')
      .send({ identifier: '' });

    expect(res.status).toBe(422);
  });

  it('should refresh token successfully', async () => {
    const loginRes = await request(app)
      .post('/api/v1/auth/login')
      .send({ identifier: 'TEST-001', password: 'Test@1234' });

    const { refreshToken } = loginRes.body.data;

    const refreshRes = await request(app)
      .post('/api/v1/auth/refresh')
      .send({ refreshToken });

    expect(refreshRes.status).toBe(200);
    expect(refreshRes.body.data.accessToken).toBeDefined();
    expect(refreshRes.body.data.refreshToken).toBeDefined();
    // New refresh token should be different (rotation)
    expect(refreshRes.body.data.refreshToken).not.toBe(refreshToken);
  });

  it('should reject disabled account', async () => {
    await User.findByIdAndUpdate(testUserId, { isActive: false });

    const res = await request(app)
      .post('/api/v1/auth/login')
      .send({ identifier: 'TEST-001', password: 'Test@1234' });

    expect(res.status).toBe(401);
    expect(res.body.error.code).toBe('ACCOUNT_DISABLED');

    await User.findByIdAndUpdate(testUserId, { isActive: true });
  });
});

describe('GET /api/v1/auth/me', () => {
  let accessToken: string;

  beforeAll(async () => {
    const hash = await bcrypt.hash('Test@1234', 12);
    await User.create({
      employeeId: 'TEST-002',
      name: 'Test Officer 2',
      email: 'test.officer2@test.kairos',
      passwordHash: hash,
      role: 'OFFICER',
      isActive: true,
    });

    const res = await request(app)
      .post('/api/v1/auth/login')
      .send({ identifier: 'TEST-002', password: 'Test@1234' });

    accessToken = res.body.data.accessToken;
  });

  it('should return current user', async () => {
    const res = await request(app)
      .get('/api/v1/auth/me')
      .set('Authorization', `Bearer ${accessToken}`);

    expect(res.status).toBe(200);
    expect(res.body.data.employeeId).toBe('TEST-002');
    expect(res.body.data.passwordHash).toBeUndefined();
  });

  it('should reject missing token', async () => {
    const res = await request(app).get('/api/v1/auth/me');
    expect(res.status).toBe(401);
    expect(res.body.error.code).toBe('MISSING_TOKEN');
  });

  it('should reject invalid token', async () => {
    const res = await request(app)
      .get('/api/v1/auth/me')
      .set('Authorization', 'Bearer invalid.token.here');
    expect(res.status).toBe(401);
    expect(res.body.error.code).toBe('INVALID_TOKEN');
  });
});
