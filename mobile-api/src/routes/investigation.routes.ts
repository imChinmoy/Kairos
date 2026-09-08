import { Router } from 'express';
import {
  listInvestigations,
  getInvestigation,
  acceptInvestigation,
  startInvestigation,
  getMapData,
  getAssignments,
  assignOfficer,
  revokeAssignment,
} from '../controllers/investigation.controller';
import {
  createInspection,
  getInspection,
} from '../controllers/inspection.controller';
import { authenticateUser } from '../middleware/authenticate';
import { authorizeRoles } from '../middleware/authorize';
import { UserRole } from '../models/User';

const router = Router();

// All investigation routes require authentication
router.use(authenticateUser);

/**
 * @swagger
 * /api/v1/investigations:
 *   get:
 *     summary: List all investigations
 *     tags: [Investigations]
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: A list of investigations
 */
router.get('/', listInvestigations);

/**
 * @swagger
 * /api/v1/investigations/{id}:
 *   get:
 *     summary: Get an investigation by ID
 *     tags: [Investigations]
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
 *         description: Investigation details
 */
router.get('/:id', getInvestigation);

/**
 * @swagger
 * /api/v1/investigations/{id}/map:
 *   get:
 *     summary: Get map data for an investigation
 *     tags: [Investigations]
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
 *         description: Map data containing spill polygons and candidate vessels
 */
router.get('/:id/map', getMapData);

/**
 * @swagger
 * /api/v1/investigations/{id}/accept:
 *   post:
 *     summary: Accept an assigned investigation
 *     tags: [Investigations]
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
 *         description: Investigation accepted
 */
router.post('/:id/accept', acceptInvestigation);

/**
 * @swagger
 * /api/v1/investigations/{id}/start:
 *   post:
 *     summary: Start travel for an investigation
 *     tags: [Investigations]
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
 *         description: Investigation started
 */
router.post('/:id/start', startInvestigation);

// Assignment management (supervisors/admins only)
/**
 * @swagger
 * /api/v1/investigations/{id}/assignments:
 *   get:
 *     summary: Get officer assignments (Admin/Supervisor only)
 *     tags: [Investigations]
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
 *         description: List of assigned officers
 */
router.get('/:id/assignments', authorizeRoles(UserRole.SUPERVISOR, UserRole.ADMIN), getAssignments);

/**
 * @swagger
 * /api/v1/investigations/{id}/assign:
 *   post:
 *     summary: Assign an officer to the investigation
 *     tags: [Investigations]
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
 *             properties:
 *               officerId:
 *                 type: string
 *     responses:
 *       200:
 *         description: Officer assigned successfully
 */
router.post('/:id/assign', authorizeRoles(UserRole.SUPERVISOR, UserRole.ADMIN), assignOfficer);

/**
 * @swagger
 * /api/v1/investigations/{id}/assign/{officerId}:
 *   delete:
 *     summary: Revoke an officer's assignment
 *     tags: [Investigations]
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *       - in: path
 *         name: officerId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Assignment revoked
 */
router.delete('/:id/assign/:officerId', authorizeRoles(UserRole.SUPERVISOR, UserRole.ADMIN), revokeAssignment);

// Inspection creation / retrieval (tied to an investigation)
/**
 * @swagger
 * /api/v1/investigations/{id}/inspection:
 *   post:
 *     summary: Create a new inspection for the investigation
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
 *       201:
 *         description: Inspection created
 */
router.post('/:id/inspection', createInspection);

/**
 * @swagger
 * /api/v1/investigations/{id}/inspection:
 *   get:
 *     summary: Get inspection for this investigation
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
 *         description: Inspection details
 */
router.get('/:id/inspection', getInspection);

export default router;
