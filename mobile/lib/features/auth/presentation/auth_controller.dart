import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../domain/dentist_model.dart';
import '../../../core/errors/app_exception.dart';

enum AuthStatus { initial, authenticating, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final DentistModel? dentist;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.dentist,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated && dentist != null;

  AuthState copyWith({
    AuthStatus? status,
    DentistModel? dentist,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      dentist: dentist ?? this.dentist,
      errorMessage: errorMessage,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final token = await _repository.getToken();
      if (token == null || token.isEmpty) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }
      final dentist = await _repository.getMe();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        dentist: dentist,
      );
    } catch (_) {
      await _repository.logout();
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);
    try {
      final result = await _repository.login(email, password);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        dentist: result.dentist,
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'An unexpected error occurred during login.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo);
});
