/**
 * KAIROS Demo Seed Script
 * Run: npm run seed
 *
 * Creates:
 * - 3 officers, 1 supervisor, 1 admin
 * - 5 investigation assignments (referencing mock FastAPI investigation IDs)
 * - 1 complete field inspection with observations
 *
 * ALL demo data is clearly marked as DEMO DATA.
 * Do NOT use in production.
 */

import dotenv from 'dotenv';
dotenv.config();

import { connectDatabase, disconnectDatabase } from '../config/database';
import { User } from '../models/User';
import { InvestigationAssignment, AssignmentStatus } from '../models/InvestigationAssignment';
import { FieldInspection, InspectionStatus, InspectionFinding } from '../models/FieldInspection';
import { FieldObservation } from '../models/FieldObservation';
import bcrypt from 'bcryptjs';

// Demo FastAPI investigation IDs (these would come from your actual FastAPI backend)
const DEMO_INVESTIGATION_IDS = [
  'demo-inv-001-arabian-sea',
  'demo-inv-002-bay-of-bengal',
  'demo-inv-003-lakshadweep',
  'demo-inv-004-andaman',
  'demo-inv-005-gujarat-coast',
];

async function seed() {
  console.log('🌱 KAIROS Seed Script — [DEMO DATA]');
  console.log('Connecting to MongoDB...');

  await connectDatabase();
  console.log('Connected.\n');

  const passwordHash = await bcrypt.hash('Demo@1234', 12);

  // ─── Clear existing demo data ────────────────────────────────────────────
  console.log('Clearing existing demo users and assignments...');
  await User.deleteMany({ employeeId: { $in: ['OFF-001', 'OFF-002', 'OFF-003', 'SUP-001', 'ADM-001'] } });
  await InvestigationAssignment.deleteMany({
    fastApiInvestigationId: { $in: DEMO_INVESTIGATION_IDS },
  });

  // ─── Create Users ────────────────────────────────────────────────────────
  console.log('Creating demo users...');

  const [officer1, officer2, officer3, supervisor, admin] = await User.create([
    {
      employeeId: 'OFF-001',
      name: '[DEMO] Arjun Mehta',
      email: 'arjun.mehta@kairos.demo',
      phone: '+91-98765-43210',
      passwordHash,
      role: 'OFFICER',
      department: 'Maritime Enforcement',
      designation: 'Field Investigation Officer',
      isActive: true,
    },
    {
      employeeId: 'OFF-002',
      name: '[DEMO] Priya Nair',
      email: 'priya.nair@kairos.demo',
      phone: '+91-98765-43211',
      passwordHash,
      role: 'OFFICER',
      department: 'Marine Environment Division',
      designation: 'Senior Field Officer',
      isActive: true,
    },
    {
      employeeId: 'OFF-003',
      name: '[DEMO] Rohan Singh',
      email: 'rohan.singh@kairos.demo',
      phone: '+91-98765-43212',
      passwordHash,
      role: 'OFFICER',
      department: 'Coastal Surveillance',
      designation: 'Investigation Officer',
      isActive: true,
    },
    {
      employeeId: 'SUP-001',
      name: '[DEMO] Commander Vikram Das',
      email: 'vikram.das@kairos.demo',
      phone: '+91-98765-43213',
      passwordHash,
      role: 'SUPERVISOR',
      department: 'Maritime Enforcement',
      designation: 'Duty Commander',
      isActive: true,
    },
    {
      employeeId: 'ADM-001',
      name: '[DEMO] NTRO Admin',
      email: 'admin@kairos.demo',
      phone: '+91-98765-43214',
      passwordHash,
      role: 'ADMIN',
      department: 'Systems Administration',
      designation: 'System Administrator',
      isActive: true,
    },
  ]);

  console.log(`✅ Created ${5} users.`);

  // ─── Create Investigation Assignments ────────────────────────────────────
  console.log('Creating investigation assignments...');

  const assignments = await InvestigationAssignment.create([
    {
      fastApiInvestigationId: DEMO_INVESTIGATION_IDS[0],
      officerId: officer1._id,
      assignedBy: supervisor._id,
      status: AssignmentStatus.IN_PROGRESS,
      priority: 'HIGH',
      notes: '[DEMO] Suspected oil spill detected near Arabian Sea shipping lane.',
      assignedAt: new Date(Date.now() - 2 * 60 * 60 * 1000),
      acceptedAt: new Date(Date.now() - 1.5 * 60 * 60 * 1000),
      startedAt: new Date(Date.now() - 60 * 60 * 1000),
    },
    {
      fastApiInvestigationId: DEMO_INVESTIGATION_IDS[1],
      officerId: officer1._id,
      assignedBy: supervisor._id,
      status: AssignmentStatus.ASSIGNED,
      priority: 'MEDIUM',
      notes: '[DEMO] Possible debris / slick detected. Bay of Bengal.',
      assignedAt: new Date(Date.now() - 24 * 60 * 60 * 1000),
    },
    {
      fastApiInvestigationId: DEMO_INVESTIGATION_IDS[2],
      officerId: officer2._id,
      assignedBy: supervisor._id,
      status: AssignmentStatus.ACCEPTED,
      priority: 'HIGH',
      notes: '[DEMO] Lakshadweep region slick. High confidence detection.',
      assignedAt: new Date(Date.now() - 3 * 60 * 60 * 1000),
      acceptedAt: new Date(Date.now() - 2 * 60 * 60 * 1000),
    },
    {
      fastApiInvestigationId: DEMO_INVESTIGATION_IDS[3],
      officerId: officer2._id,
      assignedBy: supervisor._id,
      status: AssignmentStatus.COMPLETED,
      priority: 'LOW',
      notes: '[DEMO] Andaman Islands routine check.',
      assignedAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
      acceptedAt: new Date(Date.now() - 6.5 * 24 * 60 * 60 * 1000),
      startedAt: new Date(Date.now() - 6 * 24 * 60 * 60 * 1000),
      completedAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
    },
    {
      fastApiInvestigationId: DEMO_INVESTIGATION_IDS[4],
      officerId: officer3._id,
      assignedBy: supervisor._id,
      status: AssignmentStatus.ASSIGNED,
      priority: 'CRITICAL',
      notes: '[DEMO] CRITICAL: Large slick near Gujarat coast. Immediate response required.',
      assignedAt: new Date(),
    },
  ]);

  console.log(`✅ Created ${assignments.length} investigation assignments.`);

  // ─── Create Complete Demo Field Inspection ───────────────────────────────
  console.log('Creating demo complete field inspection...');

  const inspection = await FieldInspection.create({
    fastApiInvestigationId: DEMO_INVESTIGATION_IDS[0],
    officerId: officer1._id,
    status: InspectionStatus.SUBMITTED,
    startedAt: new Date(Date.now() - 90 * 60 * 1000),
    completedAt: new Date(Date.now() - 15 * 60 * 1000),
    submittedAt: new Date(Date.now() - 10 * 60 * 1000),

    arrivalLocation: {
      latitude: 18.9388,
      longitude: 72.9153,
      accuracy: 8.5,
      altitude: 12,
      timestamp: new Date(Date.now() - 90 * 60 * 1000),
    },

    siteConditions: {
      seaState: 'MODERATE',
      visibility: 'GOOD',
      weatherCondition: 'Partly cloudy',
      windSpeed: 14,
      windDirection: 'NE',
      currentSpeed: 0.6,
      currentDirection: 'SE',
      temperature: 29,
      humidity: 78,
    },

    oilObservation: {
      visibleOil: true,
      slickArea: 2400,
      slickColor: 'Dark brown/black',
      slickThickness: 'DARK',
      odorPresent: true,
      odorDescription: 'Strong hydrocarbon odor, petroleum-like',
      notes: '[DEMO] Clearly visible oil sheen with darker patches. Estimated coverage 2400 sq m.',
    },

    environmentObservation: {
      shorelineAffected: false,
      marineLifeAffected: true,
      wildlifeObservations: 'Several seabirds observed near slick perimeter. Fish surface activity reduced.',
      debrisPresent: true,
      notes: '[DEMO] No shoreline contamination observed. Marine life activity suggests ongoing contamination.',
    },

    vesselObservations: [
      {
        vesselName: '[DEMO] Oceanic Pride',
        mmsi: '123456789',
        imoNumber: 'IMO9876543',
        flagState: 'Panama',
        vesselType: 'Oil Tanker',
        heading: 135,
        speed: 8.2,
        distance: 3.2,
        notes: '[DEMO] Candidate vessel identified. Heading southeast. AIS active.',
        observedAt: new Date(Date.now() - 60 * 60 * 1000),
        location: {
          latitude: 18.9100,
          longitude: 72.8900,
          accuracy: 15,
          timestamp: new Date(Date.now() - 60 * 60 * 1000),
        },
      },
    ],

    notes: '[DEMO] Oil spill confirmed. Source likely from vessel passing through the area 8-10 hours ago. Weather and current conditions consistent with model predictions. Recommend immediate containment response.',
    finding: InspectionFinding.OIL_CONFIRMED,
  });

  console.log(`✅ Created demo inspection: ${inspection._id}`);

  // ─── Create Demo Observations ────────────────────────────────────────────
  console.log('Creating demo observations...');

  await FieldObservation.create([
    {
      fastApiInvestigationId: DEMO_INVESTIGATION_IDS[0],
      inspectionId: inspection._id,
      officerId: officer1._id,
      type: 'VISIBLE_OIL',
      value: 'Confirmed oil slick, dark brown coloration, approx 2400 sq m',
      timestamp: new Date(Date.now() - 80 * 60 * 1000),
      latitude: 18.9388,
      longitude: 72.9153,
      accuracy: 8.5,
      notes: '[DEMO] Oil clearly visible from vessel. Strong hydrocarbon odor.',
    },
    {
      fastApiInvestigationId: DEMO_INVESTIGATION_IDS[0],
      inspectionId: inspection._id,
      officerId: officer1._id,
      type: 'WIND',
      value: '14 km/h NE',
      timestamp: new Date(Date.now() - 75 * 60 * 1000),
      latitude: 18.9388,
      longitude: 72.9153,
      accuracy: 8.5,
      notes: '[DEMO] Wind conditions: 14 km/h from NE. Consistent with model prediction of 10-15 km/h.',
    },
    {
      fastApiInvestigationId: DEMO_INVESTIGATION_IDS[0],
      inspectionId: inspection._id,
      officerId: officer1._id,
      type: 'VESSEL_SIGHTING',
      value: 'Oil Tanker "Oceanic Pride" observed 3.2 NM SE, MMSI 123456789',
      timestamp: new Date(Date.now() - 60 * 60 * 1000),
      latitude: 18.9100,
      longitude: 72.8900,
      accuracy: 15,
      notes: '[DEMO] Candidate vessel observed. AIS active. Heading 135°.',
    },
    {
      fastApiInvestigationId: DEMO_INVESTIGATION_IDS[0],
      inspectionId: inspection._id,
      officerId: officer1._id,
      type: 'WATER_CONDITION',
      value: 'Moderate sea state, 0.6 kn SE current',
      timestamp: new Date(Date.now() - 55 * 60 * 1000),
      latitude: 18.9388,
      longitude: 72.9153,
      accuracy: 8.5,
    },
    {
      fastApiInvestigationId: DEMO_INVESTIGATION_IDS[0],
      inspectionId: inspection._id,
      officerId: officer1._id,
      type: 'SEA_STATE',
      value: 'MODERATE — wave height approx 1.2m',
      timestamp: new Date(Date.now() - 50 * 60 * 1000),
      latitude: 18.9388,
      longitude: 72.9153,
      accuracy: 8.5,
    },
  ]);

  console.log('✅ Created 5 demo observations.');

  // ─── Summary ────────────────────────────────────────────────────────────
  console.log('\n' + '='.repeat(50));
  console.log('🎉 KAIROS Demo Data Seeded Successfully!');
  console.log('='.repeat(50));
  console.log('\nDemo Credentials (all use password: Demo@1234):');
  console.log('  Officer:    OFF-001 / arjun.mehta@kairos.demo');
  console.log('  Officer:    OFF-002 / priya.nair@kairos.demo');
  console.log('  Officer:    OFF-003 / rohan.singh@kairos.demo');
  console.log('  Supervisor: SUP-001 / vikram.das@kairos.demo');
  console.log('  Admin:      ADM-001 / admin@kairos.demo');
  console.log('\n⚠️  ALL DATA IS MARKED [DEMO DATA]. Do not use in production.\n');

  await disconnectDatabase();
}

seed().catch((error) => {
  console.error('Seed failed:', error);
  process.exit(1);
});
