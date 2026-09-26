import { Photo, IPhoto } from '../models/Photo.js';
import { Patient, IPatient } from '../models/Patient.js';
import { cloudinaryService } from './cloudinaryService.js';
import mongoose from 'mongoose';

export interface UploadPhotoDto {
  patientId: string;
  dentistId?: string;
  category?: string;
  documentationDate?: string | Date;
  notes?: string;
  fileBuffer: Buffer;
  originalName: string;
  mimeType: string;
  hostUrl: string;
}

export interface UpdatePhotoDto {
  notes?: string;
  category?: string;
  documentationDate?: string | Date;
}

export class PhotoService {
  /**
   * Uploads and associates a photo with a patient
   */
  async uploadPhoto(dto: UploadPhotoDto): Promise<IPhoto> {
    const patientQuery = mongoose.Types.ObjectId.isValid(dto.patientId)
      ? { _id: dto.patientId }
      : { patientId: dto.patientId };

    const patient = await Patient.findOne(patientQuery);
    if (!patient) {
      throw new Error(`Patient not found with identifier ${dto.patientId}`);
    }

    // 1. Upload to Cloudinary / storage
    const uploadResult = await cloudinaryService.uploadPhoto(
      dto.fileBuffer,
      patient.patientId,
      dto.originalName,
      dto.mimeType,
      dto.hostUrl
    );

    // 2. Parse date
    const docDate = dto.documentationDate
      ? new Date(dto.documentationDate)
      : new Date();

    // 3. Create Photo record
    const photo = await Photo.create({
      patientId: patient._id,
      dentistId: dto.dentistId ? new mongoose.Types.ObjectId(dto.dentistId) : undefined,
      cloudinaryPublicId: uploadResult.publicId,
      imageUrl: uploadResult.secureUrl,
      category: dto.category || 'General',
      documentationDate: docDate,
      notes: dto.notes || '',
    });

    // 4. Update patient latestDocumentationDate and photoCount
    const count = await Photo.countDocuments({ patientId: patient._id });
    const latestPhoto = await Photo.findOne({ patientId: patient._id }).sort({ documentationDate: -1 });

    patient.photoCount = count;
    patient.latestDocumentationDate = latestPhoto?.documentationDate || docDate;
    await patient.save();

    return photo;
  }

  /**
   * Retrieves all photos for a specific patient in chronological order
   */
  async getPatientPhotos(
    patientId: string,
    sortOrder: 'asc' | 'desc' = 'desc'
  ): Promise<{ patient: IPatient; photos: IPhoto[] }> {
    const patientQuery = mongoose.Types.ObjectId.isValid(patientId)
      ? { _id: patientId }
      : { patientId };

    const patient = await Patient.findOne(patientQuery);
    if (!patient) {
      throw new Error(`Patient not found with identifier ${patientId}`);
    }

    const sortDirection = sortOrder === 'asc' ? 1 : -1;
    const photos = await Photo.find({ patientId: patient._id }).sort({
      documentationDate: sortDirection,
      createdAt: sortDirection,
    });

    return { patient, photos };
  }

  /**
   * Gets a single photo by ID
   */
  async getPhotoById(photoId: string): Promise<IPhoto | null> {
    if (!mongoose.Types.ObjectId.isValid(photoId)) {
      return null;
    }
    return Photo.findById(photoId).populate('patientId', 'patientId name');
  }

  /**
   * Updates photo notes, category, or documentation date
   */
  async updatePhoto(photoId: string, dto: UpdatePhotoDto): Promise<IPhoto | null> {
    if (!mongoose.Types.ObjectId.isValid(photoId)) {
      return null;
    }

    const updateData: Partial<IPhoto> = {};
    if (dto.notes !== undefined) updateData.notes = dto.notes.trim();
    if (dto.category !== undefined) updateData.category = dto.category.trim();
    if (dto.documentationDate !== undefined) {
      updateData.documentationDate = new Date(dto.documentationDate);
    }

    const updated = await Photo.findByIdAndUpdate(photoId, updateData, {
      new: true,
      runValidators: true,
    });

    return updated;
  }

  /**
   * Deletes a photo and removes it from Cloudinary and updates patient's photo metadata
   */
  async deletePhoto(photoId: string): Promise<boolean> {
    if (!mongoose.Types.ObjectId.isValid(photoId)) {
      return false;
    }

    const photo = await Photo.findById(photoId);
    if (!photo) return false;

    // 1. Delete asset from Cloudinary
    await cloudinaryService.deletePhoto(photo.cloudinaryPublicId);

    // 2. Delete record from MongoDB
    await Photo.findByIdAndDelete(photoId);

    // 3. Recalculate patient stats
    const patientId = photo.patientId;
    const count = await Photo.countDocuments({ patientId });
    const latestPhoto = await Photo.findOne({ patientId }).sort({ documentationDate: -1 });

    await Patient.findByIdAndUpdate(patientId, {
      photoCount: count,
      latestDocumentationDate: latestPhoto?.documentationDate || null,
    });

    return true;
  }
}

export const photoService = new PhotoService();
