import { Router } from 'express';
import { triggerSos, getSosHistory } from '../controllers/sos.controller';
import { authenticateUser } from '../middleware/authenticate';

const router = Router();

router.use(authenticateUser);

/**
 * @swagger
 * /api/v1/sos/trigger:
 *   post:
 *     summary: Trigger an SOS emergency alert
 *     tags: [SOS]
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               latitude:
 *                 type: number
 *               longitude:
 *                 type: number
 *     responses:
 *       200:
 *         description: SOS triggered
 */
router.post('/trigger', triggerSos);

/**
 * @swagger
 * /api/v1/sos/history:
 *   get:
 *     summary: Get SOS alert history
 *     tags: [SOS]
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: List of previous SOS alerts
 */
router.get('/history', getSosHistory);

export default router;
