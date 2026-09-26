import { Patient, IPatient } from '../models/Patient.js';
import { Photo } from '../models/Photo.js';
import { cloudinaryService } from './cloudinaryService.js';
import { generatePatientId } from '../utils/idGenerator.js';
import mongoose from 'mongoose';

export interface CreatePatientDto {
  name: string;
  dateOfBirth: string | Date;
  gender: 'Male' | 'Female' | 'Other';
  phone: string;
  additionalInformation?: string;
  dentistId?: string;
}

export interface UpdatePatientDto {
  name?: string;
  dateOfBirth?: string | Date;
  gender?: 'Male' | 'Female' | 'Other';
  phone?: string;
  additionalInformation?: string;
}

export interface PatientFilter {
  search?: string;
  page?: number;
  limit?: number;
}

export class PatientService {
  /**
   * Creates a new patient with an automatically generated Patient ID
   */
  async createPatient(dto: CreatePatientDto): Promise<IPatient> {
    const totalCount = await Patient.countDocuments();
    let patientId = generatePatientId(totalCount + 1);

    // Verify uniqueness of generated patientId
    let attempts = 0;
    while (await Patient.findOne({ patientId })) {
      attempts++;
      patientId = generatePatientId(totalCount + 1 + attempts);
    }

    const patient = await Patient.create({
      patientId,
      name: dto.name.trim(),
      dateOfBirth: new Date(dto.dateOfBirth),
      gender: dto.gender,
      phone: dto.phone.trim(),
      additionalInformation: dto.additionalInformation?.trim() || '',
      dentistId: dto.dentistId ? new mongoose.Types.ObjectId(dto.dentistId) : undefined,
      photoCount: 0,
    });

    return patient;
  }

  /**
   * Retrieves patients with optional search query and pagination
   */
  async getPatients(filter: PatientFilter = {}): Promise<{
    patients: IPatient[];
    total: number;
    page: number;
    totalPages: number;
  }> {
    const page = Math.max(1, filter.page || 1);
    const limit = Math.max(1, Math.min(100, filter.limit || 20));
    const skip = (page - 1) * limit;

    const query: mongoose.FilterQuery<IPatient> = {};

    if (filter.search && filter.search.trim()) {
      const searchRegex = new RegExp(filter.search.trim(), 'i');
      query.$or = [
        { name: searchRegex },
        { patientId: searchRegex },
        { phone: searchRegex },
      ];
    }

    const [patients, total] = await Promise.all([
      Patient.find(query).sort({ createdAt: -1 }).skip(skip).limit(limit),
      Patient.countDocuments(query),
    ]);

    return {
      patients,
      total,
      page,
      totalPages: Math.ceil(total / limit),
    };
  }

  /**
   * Retrieves a single patient by MongoDB ID or Patient ID string
   */
  async getPatientById(id: string): Promise<IPatient | null> {
    if (mongoose.Types.ObjectId.isValid(id)) {
      const byMongoId = await Patient.findById(id);
      if (byMongoId) return byMongoId;
    }
    return Patient.findOne({ patientId: id });
  }

  /**
   * Updates patient details
   */
  async updatePatient(id: string, dto: UpdatePatientDto): Promise<IPatient | null> {
    const updateData: Partial<IPatient> = {};

    if (dto.name !== undefined) updateData.name = dto.name.trim();
    if (dto.dateOfBirth !== undefined) updateData.dateOfBirth = new Date(dto.dateOfBirth);
    if (dto.gender !== undefined) updateData.gender = dto.gender;
    if (dto.phone !== undefined) updateData.phone = dto.phone.trim();
    if (dto.additionalInformation !== undefined) {
      updateData.additionalInformation = dto.additionalInformation.trim();
    }

    const query = mongoose.Types.ObjectId.isValid(id)
      ? { _id: id }
      : { patientId: id };

    return Patient.findOneAndUpdate(query, updateData, { new: true, runValidators: true });
  }

  /**
   * Deletes a patient and all their associated photos from Cloudinary and MongoDB
   */
  async deletePatient(id: string): Promise<boolean> {
    const query = mongoose.Types.ObjectId.isValid(id)
      ? { _id: id }
      : { patientId: id };

    const patient = await Patient.findOne(query);
    if (!patient) return false;

    // 1. Fetch all photos for this patient
    const photos = await Photo.find({ patientId: patient._id });

    // 2. Remove all photos from Cloudinary
    const publicIds = photos.map((p) => p.cloudinaryPublicId).filter(Boolean);
    if (publicIds.length > 0) {
      await cloudinaryService.deletePhotos(publicIds);
    }

    // 3. Delete photo records from MongoDB
    await Photo.deleteMany({ patientId: patient._id });

    // 4. Delete the patient document
    await Patient.deleteOne({ _id: patient._id });

    return true;
  }
}

export const patientService = new PatientService();
