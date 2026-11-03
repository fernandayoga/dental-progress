import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../patients/domain/patient_model.dart';
import '../../photos/domain/photo_model.dart';

class DashboardData {
  final int totalPatients;
  final int totalPhotos;
  final List<PatientModel> recentPatients;
  final List<PhotoModel> recentPhotos;
  final String dentistName;

  DashboardData({
    required this.totalPatients,
    required this.totalPhotos,
    required this.recentPatients,
    required this.recentPhotos,
    required this.dentistName,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final recentPatientsList = (json['recentPatients'] as List? ?? [])
        .map((p) => PatientModel.fromJson(p))
        .toList();
    final recentPhotosList = (json['recentPhotos'] as List? ?? [])
        .map((p) => PhotoModel.fromJson(p))
        .toList();

    return DashboardData(
      totalPatients: json['totalPatients'] ?? 0,
      totalPhotos: json['totalPhotos'] ?? 0,
      recentPatients: recentPatientsList,
      recentPhotos: recentPhotosList,
      dentistName: json['dentistName'] ?? 'Dentist',
    );
  }
}

class DashboardState {
  final bool isLoading;
  final DashboardData? data;
  final String? errorMessage;

  const DashboardState({
    this.isLoading = false,
    this.data,
    this.errorMessage,
  });

  DashboardState copyWith({
    bool? isLoading,
    DashboardData? data,
    String? errorMessage,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      errorMessage: errorMessage,
    );
  }
}

class DashboardController extends StateNotifier<DashboardState> {
  final Dio _dio;

  DashboardController(this._dio) : super(const DashboardState());

  void reset() {
    state = const DashboardState();
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _dio.get(ApiEndpoints.dashboardStats);
      final data = DashboardData.fromJson(response.data['data']);
      state = state.copyWith(isLoading: false, data: data, errorMessage: null);
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: AppException.fromDio(e).message);
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to load dashboard data.');
    }
  }
}

final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, DashboardState>((ref) {
  final dio = ref.watch(dioProvider);
  final authState = ref.watch(authControllerProvider);
  final controller = DashboardController(dio);

  if (authState.isAuthenticated) {
    controller.loadDashboard();
  }

  return controller;
});
