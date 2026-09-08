import request from 'supertest';
import bcrypt from 'bcryptjs';
import { createApp } from '../app';
import { connectDatabase, disconnectDatabase } from '../config/database';
import { User } from '../models/User';
import { InvestigationAssignment, AssignmentStatus } from '../models/InvestigationAssignment';

const app = createApp();

const TEST_INV_ID = 'test-authorization-inv-001';
const OTHER_INV_ID = 'test-authorization-inv-other-999';

let officer1Token: string;
let officer2Token: string;
let supervisorToken: string;
let officer1Id: string;

beforeAll(async () => {
  await connectDatabase();
  const hash = await bcrypt.hash('Test@1234', 12);

  await User.deleteMany({ email: /@authtest\.kairos$/ });

  const [o1, o2, sup] = await User.create([
    { employeeId: 'AUTHTEST-O1', name: 'Officer One', email: 'o1@authtest.kairos', passwordHash: hash, role: 'OFFICER', isActive: true },
    { employeeId: 'AUTHTEST-O2', name: 'Officer Two', email: 'o2@authtest.kairos', passwordHash: hash, role: 'OFFICER', isActive: true },
    { employeeId: 'AUTHTEST-S1', name: 'Supervisor', email: 'sup@authtest.kairos', passwordHash: hash, role: 'SUPERVISOR', isActive: true },
  ]);

  officer1Id = o1._id.toString();

  await InvestigationAssignment.deleteMany({ fastApiInvestigationId: { $in: [TEST_INV_ID, OTHER_INV_ID] } });

  // Assign TEST_INV_ID only to officer1
  await InvestigationAssignment.create({
    fastApiInvestigationId: TEST_INV_ID,
    officerId: o1._id,
    assignedBy: sup._id,
    status: AssignmentStatus.ASSIGNED,
    priority: 'HIGH',
  });

  const [r1, r2, r3] = await Promise.all([
    request(app).post('/api/v1/auth/login').send({ identifier: 'AUTHTEST-O1', password: 'Test@1234' }),
    request(app).post('/api/v1/auth/login').send({ identifier: 'AUTHTEST-O2', password: 'Test@1234' }),
    request(app).post('/api/v1/auth/login').send({ identifier: 'AUTHTEST-S1', password: 'Test@1234' }),
  ]);

  officer1Token = r1.body.data.accessToken;
  officer2Token = r2.body.data.accessToken;
  supervisorToken = r3.body.data.accessToken;
});

afterAll(async () => {
  await User.deleteMany({ email: /@authtest\.kairos$/ });
  await InvestigationAssignment.deleteMany({ fastApiInvestigationId: { $in: [TEST_INV_ID, OTHER_INV_ID] } });
  await disconnectDatabase();
});

describe('CRITICAL: Cross-officer investigation access', () => {
  it('Officer 1 can access their assigned investigation', async () => {
    const res = await request(app)
      .get(`/api/v1/investigations/${TEST_INV_ID}`)
      .set('Authorization', `Bearer ${officer1Token}`);

    // 200 or graceful FastAPI-unavailable response — either is correct
    expect([200, 200]).toContain(res.status);
    expect(res.body.success).toBe(true);
  });

  it('CRITICAL: Officer 2 CANNOT access Officer 1\'s investigation', async () => {
    const res = await request(app)
      .get(`/api/v1/investigations/${TEST_INV_ID}`)
      .set('Authorization', `Bearer ${officer2Token}`);

    expect(res.status).toBe(403);
    expect(res.body.success).toBe(false);
    expect(res.body.error.code).toBe('INVESTIGATION_NOT_ASSIGNED');
  });

  it('Supervisor CAN access any investigation', async () => {
    const res = await request(app)
      .get(`/api/v1/investigations/${TEST_INV_ID}`)
      .set('Authorization', `Bearer ${supervisorToken}`);

    // Supervisor should not get 403
    expect(res.status).not.toBe(403);
  });

  it('Unauthenticated user cannot access investigations', async () => {
    const res = await request(app).get(`/api/v1/investigations/${TEST_INV_ID}`);
    expect(res.status).toBe(401);
  });

  it('Officer cannot list other officers\' investigations', async () => {
    const res = await request(app)
      .get('/api/v1/investigations')
      .set('Authorization', `Bearer ${officer2Token}`);

    expect(res.status).toBe(200);
    // Officer 2 has no assignments — should get empty list
    expect(res.body.data).toHaveLength(0);
  });

  it('Officer cannot assign officers (supervisor-only)', async () => {
    const res = await request(app)
      .post(`/api/v1/investigations/${TEST_INV_ID}/assign`)
      .set('Authorization', `Bearer ${officer1Token}`)
      .send({ officerId: officer1Id });

    expect(res.status).toBe(403);
  });

  it('Supervisor can assign officers', async () => {
    const res = await request(app)
      .post(`/api/v1/investigations/${TEST_INV_ID}/assign`)
      .set('Authorization', `Bearer ${supervisorToken}`)
      .send({ officerId: officer1Id, priority: 'HIGH' });

    // Either 201 (new) or 409 (already assigned) — both mean the supervisor got through auth
    expect([201, 409]).toContain(res.status);
  });
});
