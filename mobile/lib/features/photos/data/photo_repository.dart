import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../domain/photo_model.dart';

abstract class PhotoRepository {
  Future<List<PhotoModel>> getPatientPhotos(String patientId);
  Future<PhotoModel> getPhotoById(String photoId);
  Future<PhotoModel> uploadPhoto({
    required String patientId,
    String? filePath,
    Uint8List? fileBytes,
    required String fileName,
    String? category,
    DateTime? documentationDate,
    String? notes,
  });
  Future<PhotoModel> updatePhoto(
    String photoId, {
    String? notes,
    String? category,
    DateTime? documentationDate,
  });
  Future<void> deletePhoto(String photoId);
}

class PhotoRepositoryImpl implements PhotoRepository {
  final Dio _dio;

  PhotoRepositoryImpl(this._dio);

  @override
  Future<List<PhotoModel>> getPatientPhotos(String patientId) async {
    try {
      final response = await _dio.get(ApiEndpoints.patientPhotos(patientId));
      final List data = response.data['data']['photos'] ?? [];
      return data.map((json) => PhotoModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  @override
  Future<PhotoModel> getPhotoById(String photoId) async {
    try {
      final response = await _dio.get(ApiEndpoints.photo(photoId));
      return PhotoModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  @override
  Future<PhotoModel> uploadPhoto({
    required String patientId,
    String? filePath,
    Uint8List? fileBytes,
    required String fileName,
    String? category,
    DateTime? documentationDate,
    String? notes,
  }) async {
    try {
      MultipartFile multipartFile;
      if (fileBytes != null) {
        multipartFile = MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
        );
      } else if (filePath != null) {
        multipartFile = await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        );
      } else {
        throw AppException(message: 'No photo file provided for upload.');
      }

      final formData = FormData.fromMap({
        'photo': multipartFile,
        if (category != null && category.isNotEmpty) 'category': category,
        if (documentationDate != null)
          'documentationDate': documentationDate.toIso8601String(),
        if (notes != null && notes.isNotEmpty) 'notes': notes.trim(),
      });

      final response = await _dio.post(
        ApiEndpoints.patientPhotos(patientId),
        data: formData,
      );

      return PhotoModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  @override
  Future<PhotoModel> updatePhoto(
    String photoId, {
    String? notes,
    String? category,
    DateTime? documentationDate,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (notes != null) data['notes'] = notes.trim();
      if (category != null) data['category'] = category.trim();
      if (documentationDate != null) {
        data['documentationDate'] = documentationDate.toIso8601String();
      }

      final response = await _dio.patch(
        ApiEndpoints.photo(photoId),
        data: data,
      );

      return PhotoModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  @override
  Future<void> deletePhoto(String photoId) async {
    try {
      await _dio.delete(ApiEndpoints.photo(photoId));
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }
}

final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PhotoRepositoryImpl(dio);
});
