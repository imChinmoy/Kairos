import { Router } from 'express';
import {
  updateInspection,
  startInspection,
  recordArrival,
  submitInspection,
  createObservation,
  getObservations,
  updateObservation,
  deleteObservation,
  getMyInspections,
} from '../controllers/inspection.controller';
import { uploadEvidence, listEvidence } from '../controllers/evidence.controller';
import { evidenceUpload } from '../services/EvidenceService';
import { authenticateUser } from '../middleware/authenticate';
import { uploadLimiter } from '../middleware/rateLimiter';

const router = Router();

router.use(authenticateUser);

// Inspection CRUD
/**
 * @swagger
 * /api/v1/inspections:
 *   get:
 *     summary: Get all inspections for the current officer
 *     tags: [Inspections]
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: List of inspections
 */
router.get('/', getMyInspections);
/**
 * @swagger
 * /api/v1/inspections/{id}:
 *   patch:
 *     summary: Update an inspection
 *     tags: [Inspections]
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *     responses:
 *       200:
 *         description: Inspection updated
 */
router.patch('/:id', updateInspection);

/**
 * @swagger
 * /api/v1/inspections/{id}/start:
 *   post:
 *     summary: Start the inspection on-site
 *     tags: [Inspections]
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Inspection started
 */
router.post('/:id/start', startInspection);

/**
 * @swagger
 * /api/v1/inspections/{id}/arrival:
 *   post:
 *     summary: Record arrival on site
 *     tags: [Inspections]
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Arrival recorded
 */
router.post('/:id/arrival', recordArrival);

/**
 * @swagger
 * /api/v1/inspections/{id}/submit:
 *   post:
 *     summary: Submit the inspection report
 *     tags: [Inspections]
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Inspection submitted
 */
router.post('/:id/submit', submitInspection);

// Observations
/**
 * @swagger
 * /api/v1/inspections/{id}/observations:
 *   post:
 *     summary: Create an observation for an inspection
 *     tags: [Observations]
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *     responses:
 *       201:
 *         description: Observation created
 */
router.post('/:id/observations', createObservation);

/**
 * @swagger
 * /api/v1/inspections/{id}/observations:
 *   get:
 *     summary: Get observations for an inspection
 *     tags: [Observations]
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: List of observations
 */
router.get('/:id/observations', getObservations);

// Evidence upload (multipart)
/**
 * @swagger
 * /api/v1/inspections/{id}/evidence:
 *   post:
 *     summary: Upload evidence file for an inspection
 *     tags: [Evidence]
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               file:
 *                 type: string
 *                 format: binary
 *     responses:
 *       201:
 *         description: Evidence uploaded and hashed
 */
router.post('/:id/evidence', uploadLimiter, evidenceUpload.single('file'), uploadEvidence);

/**
 * @swagger
 * /api/v1/inspections/{id}/evidence:
 *   get:
 *     summary: List evidence for an inspection
 *     tags: [Evidence]
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: List of evidence items
 */
router.get('/:id/evidence', listEvidence);

export default router;
