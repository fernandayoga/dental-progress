import 'package:flutter_test/flutter_test.dart';
import 'package:dental_progress/core/utils/date_formatter.dart';
import 'package:dental_progress/core/utils/validators.dart';
import 'package:dental_progress/features/patients/domain/patient_model.dart';
import 'package:dental_progress/features/photos/domain/photo_model.dart';

void main() {
  group('DateFormatter & Validators Tests', () {
    test('DateFormatter formats and calculates age accurately', () {
      final dob = DateTime(2000, 1, 1);
      final formatted = DateFormatter.format(dob);
      expect(formatted, contains('2000'));

      final ageStr = DateFormatter.calculateAge(dob);
      expect(ageStr, contains('yrs'));
    });

    test('Validators validate email, password, and phone', () {
      expect(Validators.email('invalid-email'), isNotNull);
      expect(Validators.email('dentist@example.com'), isNull);

      expect(Validators.password('123'), isNotNull);
      expect(Validators.password('password123'), isNull);

      expect(Validators.phone(''), isNotNull);
      expect(Validators.phone('+15551234567'), isNull);

      expect(Validators.required(''), isNotNull);
      expect(Validators.required('John'), isNull);
    });
  });

  group('Domain Models Tests', () {
    test('PatientModel serialization & deserialization', () {
      final json = {
        '_id': 'p123',
        'patientId': 'DP-2026-0001',
        'name': 'Alexander Vance',
        'dateOfBirth': '1995-04-12T00:00:00.000Z',
        'gender': 'Male',
        'phone': '+1 555-019-2834',
        'additionalInformation': 'Class II Malocclusion',
        'photoCount': 3,
      };

      final patient = PatientModel.fromJson(json);
      expect(patient.id, 'p123');
      expect(patient.patientId, 'DP-2026-0001');
      expect(patient.name, 'Alexander Vance');
      expect(patient.gender, 'Male');
      expect(patient.photoCount, 3);
      expect(patient.additionalInformation, 'Class II Malocclusion');

      final serialized = patient.toJson();
      expect(serialized['name'], 'Alexander Vance');
      expect(serialized['gender'], 'Male');
    });

    test('PhotoModel serialization & deserialization', () {
      final json = {
        '_id': 'ph456',
        'patientId': 'p123',
        'cloudinaryPublicId': 'dental_progress/patients/p123/img1',
        'imageUrl': 'https://res.cloudinary.com/demo/image/upload/v1/sample.jpg',
        'category': 'Frontal Smile',
        'documentationDate': '2026-09-01T10:00:00.000Z',
        'notes': 'Baseline smile photo before bracket placement.',
      };

      final photo = PhotoModel.fromJson(json);
      expect(photo.id, 'ph456');
      expect(photo.patientId, 'p123');
      expect(photo.category, 'Frontal Smile');
      expect(photo.notes, contains('Baseline smile'));
      expect(photo.imageUrl, contains('sample.jpg'));
    });
  });
}
