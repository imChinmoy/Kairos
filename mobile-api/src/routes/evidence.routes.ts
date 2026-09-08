import { Router } from 'express';
import { getEvidenceById, deleteEvidence } from '../controllers/evidence.controller';
import { updateObservation, deleteObservation } from '../controllers/inspection.controller';
import { authenticateUser } from '../middleware/authenticate';

const router = Router();

router.use(authenticateUser);

// Stand-alone evidence routes
/**
 * @swagger
 * /api/v1/evidence/{id}:
 *   get:
 *     summary: Get evidence details by ID
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
 *         description: Evidence metadata
 */
router.get('/:id', getEvidenceById);

/**
 * @swagger
 * /api/v1/evidence/{id}:
 *   delete:
 *     summary: Delete an evidence record
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
 *         description: Evidence deleted
 */
router.delete('/:id', deleteEvidence);

export default router;
