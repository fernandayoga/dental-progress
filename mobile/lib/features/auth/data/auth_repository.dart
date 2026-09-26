import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/auth_interceptor.dart';
import '../../../core/network/dio_client.dart';
import '../domain/dentist_model.dart';

abstract class AuthRepository {
  Future<({DentistModel dentist, String token})> login(String email, String password);
  Future<({DentistModel dentist, String token})> register(String name, String email, String password);
  Future<DentistModel> getMe();
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepositoryImpl(this._dio, this._storage);

  @override
  Future<({DentistModel dentist, String token})> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'email': email.trim(), 'password': password},
      );
      final data = response.data['data'];
      final dentist = DentistModel.fromJson(data['dentist']);
      final token = data['token'] as String;
      await saveToken(token);
      return (dentist: dentist, token: token);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  @override
  Future<({DentistModel dentist, String token})> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: {'name': name.trim(), 'email': email.trim(), 'password': password},
      );
      final data = response.data['data'];
      final dentist = DentistModel.fromJson(data['dentist']);
      final token = data['token'] as String;
      await saveToken(token);
      return (dentist: dentist, token: token);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  @override
  Future<DentistModel> getMe() async {
    try {
      final response = await _dio.get(ApiEndpoints.me);
      final data = response.data['data'];
      return DentistModel.fromJson(data);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  @override
  Future<void> saveToken(String token) async {
    await _storage.write(key: AuthInterceptor.tokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    return _storage.read(key: AuthInterceptor.tokenKey);
  }

  @override
  Future<void> logout() async {
    await _storage.delete(key: AuthInterceptor.tokenKey);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepositoryImpl(dio, storage);
});
