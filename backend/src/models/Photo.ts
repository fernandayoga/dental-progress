import mongoose, { Document, Schema } from 'mongoose';

export interface IPhoto extends Document {
  patientId: mongoose.Types.ObjectId;
  dentistId?: mongoose.Types.ObjectId;
  cloudinaryPublicId: string;
  imageUrl: string;
  category: string;
  documentationDate: Date;
  notes: string;
  createdAt: Date;
  updatedAt: Date;
}

const PhotoSchema = new Schema<IPhoto>(
  {
    patientId: {
      type: Schema.Types.ObjectId,
      ref: 'Patient',
      required: [true, 'Patient reference is required'],
      index: true,
    },
    dentistId: {
      type: Schema.Types.ObjectId,
      ref: 'Dentist',
      index: true,
    },
    cloudinaryPublicId: {
      type: String,
      required: [true, 'Cloudinary public ID or storage key is required'],
      trim: true,
    },
    imageUrl: {
      type: String,
      required: [true, 'Image URL is required'],
      trim: true,
    },
    category: {
      type: String,
      default: 'General',
      trim: true,
    },
    documentationDate: {
      type: Date,
      required: [true, 'Documentation date is required'],
      default: Date.now,
      index: true,
    },
    notes: {
      type: String,
      trim: true,
      maxlength: [1000, 'Notes cannot exceed 1000 characters'],
      default: '',
    },
  },
  {
    timestamps: true,
    toJSON: {
      transform: (_doc, ret) => {
        delete (ret as Record<string, unknown>).__v;
        return ret;
      },
    },
  }
);

PhotoSchema.index({ patientId: 1, documentationDate: -1 });

export const Photo = mongoose.model<IPhoto>('Photo', PhotoSchema);
