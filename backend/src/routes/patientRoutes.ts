import { Router } from 'express';
import {
  getPatients,
  getPatientById,
  createPatient,
  updatePatient,
  deletePatient,
} from '../controllers/patientController.js';
import {
  uploadPhoto,
  getPatientPhotos,
} from '../controllers/photoController.js';
import { authenticateJwt } from '../middleware/authMiddleware.js';
import { validatePatient } from '../middleware/validate.js';
import { uploadSinglePhoto } from '../middleware/uploadMiddleware.js';

const router = Router();

// Protect all patient routes with JWT auth
router.use(authenticateJwt);

router.get('/', getPatients);
router.get('/:id', getPatientById);
router.post('/', validatePatient, createPatient);
router.patch('/:id', updatePatient);
router.delete('/:id', deletePatient);

// Nested routes for patient photos (as specified in REST API specifications)
router.get('/:patientId/photos', getPatientPhotos);
router.post('/:patientId/photos', uploadSinglePhoto, uploadPhoto);

export default router;
