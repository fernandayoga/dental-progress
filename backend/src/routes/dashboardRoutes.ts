import { Router } from 'express';
import { getDashboardStats } from '../controllers/dashboardController.js';
import { authenticateJwt } from '../middleware/authMiddleware.js';

const router = Router();

router.use(authenticateJwt);
router.get('/stats', getDashboardStats);

export default router;
