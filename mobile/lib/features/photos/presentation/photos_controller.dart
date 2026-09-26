import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exception.dart';
import '../data/photo_repository.dart';
import '../domain/photo_model.dart';
import '../../patients/presentation/patients_controller.dart';

class PatientPhotosState {
  final bool isLoading;
  final bool isUploading;
  final List<PhotoModel> photos;
  final String? errorMessage;

  const PatientPhotosState({
    this.isLoading = false,
    this.isUploading = false,
    this.photos = const [],
    this.errorMessage,
  });

  PatientPhotosState copyWith({
    bool? isLoading,
    bool? isUploading,
    List<PhotoModel>? photos,
    String? errorMessage,
  }) {
    return PatientPhotosState(
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      photos: photos ?? this.photos,
      errorMessage: errorMessage,
    );
  }
}

class PatientPhotosController extends StateNotifier<PatientPhotosState> {
  final PhotoRepository _repository;
  final String patientId;
  final Ref _ref;

  PatientPhotosController(this._repository, this.patientId, this._ref)
      : super(const PatientPhotosState()) {
    loadPhotos();
  }

  Future<void> loadPhotos() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final photos = await _repository.getPatientPhotos(patientId);
      state = state.copyWith(isLoading: false, photos: photos);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load patient photos.',
      );
    }
  }

  Future<PhotoModel?> uploadPhoto({
    String? filePath,
    Uint8List? fileBytes,
    required String fileName,
    String? category,
    DateTime? documentationDate,
    String? notes,
  }) async {
    state = state.copyWith(isUploading: true, errorMessage: null);
    try {
      final newPhoto = await _repository.uploadPhoto(
        patientId: patientId,
        filePath: filePath,
        fileBytes: fileBytes,
        fileName: fileName,
        category: category,
        documentationDate: documentationDate,
        notes: notes,
      );
      state = state.copyWith(
        isUploading: false,
        photos: [newPhoto, ...state.photos],
      );
      // Refresh patient list to update count/latest date
      _ref.read(patientsControllerProvider.notifier).loadPatients();
      return newPhoto;
    } on AppException catch (e) {
      state = state.copyWith(isUploading: false, errorMessage: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: 'An unexpected error occurred during photo upload.',
      );
      rethrow;
    }
  }

  Future<PhotoModel?> updatePhoto(
    String photoId, {
    String? notes,
    String? category,
    DateTime? documentationDate,
  }) async {
    try {
      final updated = await _repository.updatePhoto(
        photoId,
        notes: notes,
        category: category,
        documentationDate: documentationDate,
      );
      final list = state.photos.map((p) => p.id == photoId ? updated : p).toList();
      state = state.copyWith(photos: list);
      return updated;
    } on AppException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      rethrow;
    }
  }

  Future<bool> deletePhoto(String photoId) async {
    try {
      await _repository.deletePhoto(photoId);
      final list = state.photos.where((p) => p.id != photoId).toList();
      state = state.copyWith(photos: list);
      // Refresh patient list to update stats
      _ref.read(patientsControllerProvider.notifier).loadPatients();
      return true;
    } on AppException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return false;
    }
  }
}

final patientPhotosControllerProvider = StateNotifierProvider.family<
    PatientPhotosController, PatientPhotosState, String>((ref, patientId) {
  final repo = ref.watch(photoRepositoryProvider);
  return PatientPhotosController(repo, patientId, ref);
});

// Single photo detail provider
final photoDetailProvider =
    FutureProvider.family<PhotoModel, String>((ref, photoId) async {
  final repo = ref.watch(photoRepositoryProvider);
  return repo.getPhotoById(photoId);
});
