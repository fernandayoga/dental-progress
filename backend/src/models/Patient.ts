import mongoose, { Document, Schema } from 'mongoose';

export interface IPatient extends Document {
  patientId: string;
  name: string;
  dateOfBirth: Date;
  gender: 'Male' | 'Female' | 'Other';
  phone: string;
  additionalInformation?: string;
  dentistId?: mongoose.Types.ObjectId;
  latestDocumentationDate?: Date;
  photoCount?: number;
  createdAt: Date;
  updatedAt: Date;
}

const PatientSchema = new Schema<IPatient>(
  {
    patientId: {
      type: String,
      required: [true, 'Patient ID is required'],
      unique: true,
      trim: true,
      index: true,
    },
    name: {
      type: String,
      required: [true, 'Patient full name is required'],
      trim: true,
      index: true,
    },
    dateOfBirth: {
      type: Date,
      required: [true, 'Date of birth is required'],
    },
    gender: {
      type: String,
      enum: {
        values: ['Male', 'Female', 'Other'],
        message: '{VALUE} is not a supported gender',
      },
      required: [true, 'Gender is required'],
    },
    phone: {
      type: String,
      required: [true, 'Phone number is required'],
      trim: true,
    },
    additionalInformation: {
      type: String,
      trim: true,
      default: '',
    },
    dentistId: {
      type: Schema.Types.ObjectId,
      ref: 'Dentist',
      index: true,
    },
    latestDocumentationDate: {
      type: Date,
    },
    photoCount: {
      type: Number,
      default: 0,
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

// Compound text index for search across patientId, name, and phone
PatientSchema.index({ name: 'text', patientId: 'text', phone: 'text' });
PatientSchema.index({ createdAt: -1 });

export const Patient = mongoose.model<IPatient>('Patient', PatientSchema);
