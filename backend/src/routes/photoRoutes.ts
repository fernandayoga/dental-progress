import { Router } from 'express';
import {
  getPhotoById,
  updatePhoto,
  deletePhoto,
} from '../controllers/photoController.js';
import { authenticateJwt } from '../middleware/authMiddleware.js';

const router = Router();

// Protect all photo routes with JWT auth
router.use(authenticateJwt);

router.get('/:id', getPhotoById);
router.patch('/:id', updatePhoto);
router.delete('/:id', deletePhoto);

export default router;
