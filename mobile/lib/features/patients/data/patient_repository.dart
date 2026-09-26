import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../domain/patient_model.dart';

abstract class PatientRepository {
  Future<List<PatientModel>> getPatients({String? search, int page = 1, int limit = 50});
  Future<PatientModel> getPatientById(String id);
  Future<PatientModel> createPatient({
    required String name,
    required DateTime dateOfBirth,
    required String gender,
    required String phone,
    String? additionalInformation,
  });
  Future<PatientModel> updatePatient({
    required String id,
    String? name,
    DateTime? dateOfBirth,
    String? gender,
    String? phone,
    String? additionalInformation,
  });
  Future<void> deletePatient(String id);
}

class PatientRepositoryImpl implements PatientRepository {
  final Dio _dio;

  PatientRepositoryImpl(this._dio);

  @override
  Future<List<PatientModel>> getPatients({
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await _dio.get(
        ApiEndpoints.patients,
        queryParameters: queryParams,
      );

      final List data = response.data['data'] ?? [];
      return data.map((json) => PatientModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  @override
  Future<PatientModel> getPatientById(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.patient(id));
      return PatientModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  @override
  Future<PatientModel> createPatient({
    required String name,
    required DateTime dateOfBirth,
    required String gender,
    required String phone,
    String? additionalInformation,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.patients,
        data: {
          'name': name.trim(),
          'dateOfBirth': dateOfBirth.toIso8601String(),
          'gender': gender,
          'phone': phone.trim(),
          if (additionalInformation != null && additionalInformation.trim().isNotEmpty)
            'additionalInformation': additionalInformation.trim(),
        },
      );
      return PatientModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  @override
  Future<PatientModel> updatePatient({
    required String id,
    String? name,
    DateTime? dateOfBirth,
    String? gender,
    String? phone,
    String? additionalInformation,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name.trim();
      if (dateOfBirth != null) data['dateOfBirth'] = dateOfBirth.toIso8601String();
      if (gender != null) data['gender'] = gender;
      if (phone != null) data['phone'] = phone.trim();
      if (additionalInformation != null) data['additionalInformation'] = additionalInformation.trim();

      final response = await _dio.patch(
        ApiEndpoints.patient(id),
        data: data,
      );
      return PatientModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  @override
  Future<void> deletePatient(String id) async {
    try {
      await _dio.delete(ApiEndpoints.patient(id));
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }
}

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PatientRepositoryImpl(dio);
});
