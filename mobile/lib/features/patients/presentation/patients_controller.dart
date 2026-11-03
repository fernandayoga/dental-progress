import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exception.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/patient_repository.dart';
import '../domain/patient_model.dart';

class PatientsState {
  final bool isLoading;
  final List<PatientModel> patients;
  final String searchQuery;
  final String? errorMessage;

  const PatientsState({
    this.isLoading = false,
    this.patients = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  PatientsState copyWith({
    bool? isLoading,
    List<PatientModel>? patients,
    String? searchQuery,
    String? errorMessage,
  }) {
    return PatientsState(
      isLoading: isLoading ?? this.isLoading,
      patients: patients ?? this.patients,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}

class PatientsController extends StateNotifier<PatientsState> {
  final PatientRepository _repository;

  PatientsController(this._repository) : super(const PatientsState());

  void reset() {
    state = const PatientsState();
  }

  Future<void> loadPatients({String? query}) async {
    final search = query ?? state.searchQuery;
    state = state.copyWith(isLoading: true, errorMessage: null, searchQuery: search);
    try {
      final list = await _repository.getPatients(search: search);
      state = state.copyWith(isLoading: false, patients: list);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load patients list.',
      );
    }
  }

  void onSearchChanged(String query) {
    state = state.copyWith(searchQuery: query);
    loadPatients(query: query);
  }

  Future<PatientModel?> createPatient({
    required String name,
    required DateTime dateOfBirth,
    required String gender,
    required String phone,
    String? additionalInformation,
  }) async {
    try {
      final newPatient = await _repository.createPatient(
        name: name,
        dateOfBirth: dateOfBirth,
        gender: gender,
        phone: phone,
        additionalInformation: additionalInformation,
      );
      state = state.copyWith(patients: [newPatient, ...state.patients]);
      return newPatient;
    } on AppException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      rethrow;
    }
  }

  Future<PatientModel?> updatePatient({
    required String id,
    String? name,
    DateTime? dateOfBirth,
    String? gender,
    String? phone,
    String? additionalInformation,
  }) async {
    try {
      final updated = await _repository.updatePatient(
        id: id,
        name: name,
        dateOfBirth: dateOfBirth,
        gender: gender,
        phone: phone,
        additionalInformation: additionalInformation,
      );
      final updatedList = state.patients.map((p) => p.id == id ? updated : p).toList();
      state = state.copyWith(patients: updatedList);
      return updated;
    } on AppException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      rethrow;
    }
  }

  Future<bool> deletePatient(String id) async {
    try {
      await _repository.deletePatient(id);
      final updatedList = state.patients.where((p) => p.id != id).toList();
      state = state.copyWith(patients: updatedList);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return false;
    }
  }
}

final patientsControllerProvider =
    StateNotifierProvider<PatientsController, PatientsState>((ref) {
  final repo = ref.watch(patientRepositoryProvider);
  final authState = ref.watch(authControllerProvider);
  final controller = PatientsController(repo);

  if (authState.isAuthenticated) {
    controller.loadPatients();
  }

  return controller;
});

// Single patient provider
final patientDetailProvider =
    FutureProvider.family<PatientModel, String>((ref, id) async {
  final repo = ref.watch(patientRepositoryProvider);
  return repo.getPatientById(id);
});
