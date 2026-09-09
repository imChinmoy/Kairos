import { Router } from 'express';
import { login, refresh, logout, getMe, updateFcmToken } from '../controllers/auth.controller';
import { authenticateUser } from '../middleware/authenticate';
import { authLimiter } from '../middleware/rateLimiter';

const router = Router();

/**
 * @swagger
 * /api/v1/auth/login:
 *   post:
 *     summary: Login with employee ID or email
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [identifier, password]
 *             properties:
 *               identifier:
 *                 type: string
 *                 description: Employee ID (e.g. OFF-001) or email address
 *               password:
 *                 type: string
 *                 format: password
 *     responses:
 *       200:
 *         description: Login successful
 *       401:
 *         description: Invalid credentials
 */
router.post('/login', authLimiter, login);
router.post('/refresh', refresh);
router.post('/logout', authenticateUser, logout);
router.get('/me', authenticateUser, getMe);
router.put('/fcm-token', authenticateUser, updateFcmToken);

export default router;
