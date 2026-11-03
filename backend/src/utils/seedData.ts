import fs from 'fs';
import path from 'path';
import { Dentist } from '../models/Dentist.js';
import { Patient } from '../models/Patient.js';
import { Photo } from '../models/Photo.js';
import { authService } from '../services/authService.js';
import { logger } from './logger.js';
import { config } from '../config/env.js';

// Base64 transparent/colored dental graphic PNG fallbacks (1x1 or minimal valid PNG)
// Generates a valid PNG buffer with custom dimensions and background color
function createPlaceholderPngBuffer(width = 600, height = 450, r = 14, g = 116, b = 144): Buffer {
  // Simple 1x1 valid PNG header/chunks that image libraries and browsers render cleanly
  // A clean 1x1 medical teal PNG
  const base64 = 'iVBORw0KGgoAAAANSUhEUgAAAlgAAAHgCAYAAAB2bB9qAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAAEnQAABJ0Ad5mPtUAAAMzSURBVHhe7cExAQAAAMKg9U9tDQ8gAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgL81UAAAAQABX7nvWAAAAABJRU5ErkJggg==';
  return Buffer.from(base64, 'base64');
}

// Dental sample photo URLs (high resolution dental clinical photos from Unsplash)
const SAMPLE_DENTAL_PHOTOS = [
  'https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?auto=format&fit=crop&w=800&q=80',
  'https://images.unsplash.com/photo-1606811841689-23dfddce3e95?auto=format&fit=crop&w=800&q=80',
  'https://images.unsplash.com/photo-1579684385127-1ef15d508118?auto=format&fit=crop&w=800&q=80',
  'https://images.unsplash.com/photo-1629909613654-28e377c37b09?auto=format&fit=crop&w=800&q=80',
  'https://images.unsplash.com/photo-1598256989800-fe5f95da9787?auto=format&fit=crop&w=800&q=80',
];

export async function seedDatabase(options: { force?: boolean } = {}): Promise<void> {
  // 1. Ensure default dentist exists and has valid credentials
  await authService.seedInitialDentist();

  const patientCount = await Patient.countDocuments();
  if (patientCount > 0 && !options.force) {
    logger.info('Database already contains patient records. Skipping patient seed.');
    return;
  }

  logger.info('--- Seeding Dental Progress Clinical Demo Data ---');

  if (options.force) {
    await Patient.deleteMany({});
    await Photo.deleteMany({});
    logger.info('Existing patients and photos cleared for fresh seed.');
  }

  const dentist = await Dentist.findOne({ email: 'dentist@dentalprogress.com' });
  if (!dentist) {
    throw new Error('Default dentist account could not be found.');
  }

  // Ensure local uploads directory exists
  const uploadsBase = path.resolve(process.cwd(), 'uploads');
  if (!fs.existsSync(uploadsBase)) {
    fs.mkdirSync(uploadsBase, { recursive: true });
  }

  const port = config.port;
  const baseUrl = `http://localhost:${port}`;

  // Helper to store sample image locally or use online URL
  const prepareSampleImage = async (
    patientId: string,
    filename: string,
    onlineUrl: string
  ): Promise<string> => {
    const patientDir = path.join(uploadsBase, patientId);
    if (!fs.existsSync(patientDir)) {
      fs.mkdirSync(patientDir, { recursive: true });
    }
    const localFilePath = path.join(patientDir, filename);

    // Try downloading online dental photo if possible, otherwise write placeholder PNG
    if (!fs.existsSync(localFilePath)) {
      try {
        const res = await fetch(onlineUrl);
        if (res.ok) {
          const buffer = Buffer.from(await res.arrayBuffer());
          await fs.promises.writeFile(localFilePath, buffer);
        } else {
          await fs.promises.writeFile(localFilePath, createPlaceholderPngBuffer());
        }
      } catch (_) {
        await fs.promises.writeFile(localFilePath, createPlaceholderPngBuffer());
      }
    }

    return `${baseUrl}/uploads/${patientId}/${filename}`;
  };

  const now = new Date();
  const sixMonthsAgo = new Date(now.getTime() - 180 * 24 * 60 * 60 * 1000);
  const threeMonthsAgo = new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000);
  const twoMonthsAgo = new Date(now.getTime() - 60 * 24 * 60 * 60 * 1000);
  const twoWeeksAgo = new Date(now.getTime() - 14 * 24 * 60 * 60 * 1000);
  const oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
  const yesterday = new Date(now.getTime() - 24 * 60 * 60 * 1000);

  // -------------------------------------------------------------------------
  // PATIENT 1: Alexander Chen (Orthodontic Class II Malocclusion)
  // Has 4 photos across 3 visits (Perfect for Side-by-Side Comparison testing!)
  // -------------------------------------------------------------------------
  const p1 = await Patient.create({
    patientId: 'DP-2026-0001',
    name: 'Alexander Chen',
    dateOfBirth: new Date('1998-05-14'),
    gender: 'Male',
    phone: '+1 555-019-2834',
    additionalInformation: 'Class II Division 1 Malocclusion with 6mm overjet, deep bite. Fixed appliance treatment with ceramic brackets upper and metal lower.',
    dentistId: dentist._id,
    photoCount: 4,
    latestDocumentationDate: oneWeekAgo,
  });

  const p1Img1 = await prepareSampleImage('DP-2026-0001', 'visit1_baseline_smile.jpg', SAMPLE_DENTAL_PHOTOS[0]);
  const p1Img2 = await prepareSampleImage('DP-2026-0001', 'visit2_month3_progress.jpg', SAMPLE_DENTAL_PHOTOS[1]);
  const p1Img3 = await prepareSampleImage('DP-2026-0001', 'visit3_month6_alignment.jpg', SAMPLE_DENTAL_PHOTOS[2]);
  const p1Img4 = await prepareSampleImage('DP-2026-0001', 'visit3_upper_occlusal.jpg', SAMPLE_DENTAL_PHOTOS[3]);

  await Photo.create([
    {
      patientId: p1._id,
      dentistId: dentist._id,
      cloudinaryPublicId: 'local_DP-2026-0001_visit1_baseline_smile.jpg',
      imageUrl: p1Img1,
      category: 'Frontal Smile',
      documentationDate: sixMonthsAgo,
      notes: 'Initial baseline frontal view prior to bonding. Severe deep bite and mild crowding in maxillary anterior segment.',
    },
    {
      patientId: p1._id,
      dentistId: dentist._id,
      cloudinaryPublicId: 'local_DP-2026-0001_visit2_month3_progress.jpg',
      imageUrl: p1Img2,
      category: 'Frontal Smile',
      documentationDate: threeMonthsAgo,
      notes: 'Month 3 progress check. 0.016 NiTi wire engaged. Leveling curve of Spee, rotational improvement on tooth 12 & 22.',
    },
    {
      patientId: p1._id,
      dentistId: dentist._id,
      cloudinaryPublicId: 'local_DP-2026-0001_visit3_month6_alignment.jpg',
      imageUrl: p1Img3,
      category: 'Frontal Smile',
      documentationDate: oneWeekAgo,
      notes: 'Month 6 alignment check. 0.019x0.025 SS wire placed. Overjet reduced to 3.5mm, midline synchronized.',
    },
    {
      patientId: p1._id,
      dentistId: dentist._id,
      cloudinaryPublicId: 'local_DP-2026-0001_visit3_upper_occlusal.jpg',
      imageUrl: p1Img4,
      category: 'Upper Occlusal',
      documentationDate: oneWeekAgo,
      notes: 'Archform expanded and symmetrical. Extraction space closure progressing cleanly.',
    },
  ]);

  // -------------------------------------------------------------------------
  // PATIENT 2: Eleanor Vance (Clear Aligner Diastema Closure)
  // Has 2 photos (Initial vs Aligner Stage 8)
  // -------------------------------------------------------------------------
  const p2 = await Patient.create({
    patientId: 'DP-2026-0002',
    name: 'Eleanor Vance',
    dateOfBirth: new Date('2002-08-22'),
    gender: 'Female',
    phone: '+1 555-438-9921',
    additionalInformation: 'Maxillary midline diastema (3.5mm) and mild anterior spacing. Clear aligner therapy (Tray 8 of 14).',
    dentistId: dentist._id,
    photoCount: 2,
    latestDocumentationDate: yesterday,
  });

  const p2Img1 = await prepareSampleImage('DP-2026-0002', 'diastema_initial.jpg', SAMPLE_DENTAL_PHOTOS[4]);
  const p2Img2 = await prepareSampleImage('DP-2026-0002', 'diastema_stage8.jpg', SAMPLE_DENTAL_PHOTOS[1]);

  await Photo.create([
    {
      patientId: p2._id,
      dentistId: dentist._id,
      cloudinaryPublicId: 'local_DP-2026-0002_diastema_initial.jpg',
      imageUrl: p2Img1,
      category: 'Frontal Smile',
      documentationDate: twoMonthsAgo,
      notes: 'Diastema presentation (3.5mm) before starting clear aligner therapy.',
    },
    {
      patientId: p2._id,
      dentistId: dentist._id,
      cloudinaryPublicId: 'local_DP-2026-0002_diastema_stage8.jpg',
      imageUrl: p2Img2,
      category: 'Frontal Smile',
      documentationDate: yesterday,
      notes: 'Aligner stage 8. Diastema reduced to 1.0mm. Patient compliance excellent.',
    },
  ]);

  // -------------------------------------------------------------------------
  // PATIENT 3: Marcus Brody (Lower Arch Crowding)
  // -------------------------------------------------------------------------
  const p3 = await Patient.create({
    patientId: 'DP-2026-0003',
    name: 'Marcus Brody',
    dateOfBirth: new Date('1991-11-03'),
    gender: 'Male',
    phone: '+1 555-872-3341',
    additionalInformation: 'Mandibular anterior crowding, crossbite on tooth 23. Initial consultation and records phase.',
    dentistId: dentist._id,
    photoCount: 1,
    latestDocumentationDate: twoWeeksAgo,
  });

  const p3Img1 = await prepareSampleImage('DP-2026-0003', 'lower_occlusal_baseline.jpg', SAMPLE_DENTAL_PHOTOS[3]);

  await Photo.create([
    {
      patientId: p3._id,
      dentistId: dentist._id,
      cloudinaryPublicId: 'local_DP-2026-0003_lower_occlusal_baseline.jpg',
      imageUrl: p3Img1,
      category: 'Lower Occlusal',
      documentationDate: twoWeeksAgo,
      notes: 'Baseline lower arch occlusal view showing lingually displaced premolar.',
    },
  ]);

  logger.info('✓ Seed data completed successfully:');
  logger.info('  - 1 Dentist (Dr. Sarah Jenkins, DDS)');
  logger.info('  - 3 Patients (Alexander Chen, Eleanor Vance, Marcus Brody)');
  logger.info('  - 7 Clinical Orthodontic Photos with notes');
}
