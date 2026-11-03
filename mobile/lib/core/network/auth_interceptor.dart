import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  static const String tokenKey = 'dp_auth_jwt_token';

  AuthInterceptor(this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _storage.read(key: tokenKey);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // Storage read error ignored
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Only delete the stored token if this was an authenticated request where a token was rejected
      final hadAuth = err.requestOptions.headers.containsKey('Authorization');
      if (hadAuth && !err.requestOptions.path.contains('/auth/login')) {
        _storage.delete(key: tokenKey).catchError((_) {});
      }
    }
    return handler.next(err);
  }
}
