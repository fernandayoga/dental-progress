import { Router } from 'express';
import { login, register, getMe } from '../controllers/authController.js';
import { validateLogin, validateRegister } from '../middleware/validate.js';
import { authenticateJwt } from '../middleware/authMiddleware.js';

const router = Router();

router.post('/register', validateRegister, register);
router.post('/login', validateLogin, login);
router.get('/me', authenticateJwt, getMe);

export default router;
