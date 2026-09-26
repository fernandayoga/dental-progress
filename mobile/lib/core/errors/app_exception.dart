import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  AppException({
    required this.message,
    this.statusCode,
    this.details,
  });

  factory AppException.fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException(
          message: 'Connection timed out. Please check your network.',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.badResponse:
        final res = error.response;
        String msg = 'An unexpected server error occurred.';
        dynamic errors;
        if (res?.data is Map<String, dynamic>) {
          msg = res?.data['message'] ?? msg;
          errors = res?.data['errors'];
        }
        return AppException(
          message: msg,
          statusCode: res?.statusCode,
          details: errors,
        );
      case DioExceptionType.cancel:
        return AppException(message: 'Request was cancelled.');
      case DioExceptionType.connectionError:
        return AppException(
          message: 'Unable to connect to server. Please ensure the backend is running.',
        );
      default:
        return AppException(
          message: error.message ?? 'An unexpected network error occurred.',
        );
    }
  }

  @override
  String toString() => message;
}
