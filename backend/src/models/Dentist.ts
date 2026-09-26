import mongoose, { Document, Schema } from 'mongoose';

export interface IDentist extends Document {
  name: string;
  email: string;
  passwordHash: string;
  createdAt: Date;
  updatedAt: Date;
}

const DentistSchema = new Schema<IDentist>(
  {
    name: {
      type: String,
      required: [true, 'Dentist name is required'],
      trim: true,
      maxlength: 100,
    },
    email: {
      type: String,
      required: [true, 'Email is required'],
      unique: true,
      lowercase: true,
      trim: true,
      index: true,
      match: [/^\S+@\S+\.\S+$/, 'Please provide a valid email address'],
    },
    passwordHash: {
      type: String,
      required: [true, 'Password hash is required'],
    },
  },
  {
    timestamps: true,
    toJSON: {
      transform: (_doc, ret) => {
        delete (ret as Record<string, unknown>).passwordHash;
        delete (ret as Record<string, unknown>).__v;
        return ret;
      },
    },
  }
);

export const Dentist = mongoose.model<IDentist>('Dentist', DentistSchema);
