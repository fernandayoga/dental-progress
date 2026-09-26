import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dental_progress/app/app.dart';
import 'package:dental_progress/features/auth/data/auth_repository.dart';
import 'package:dental_progress/features/auth/domain/dentist_model.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<({DentistModel dentist, String token})> login(String email, String password) async {
    return (
      dentist: DentistModel(id: 'd1', name: 'Dr. Test', email: email),
      token: 'fake_jwt_token',
    );
  }

  @override
  Future<({DentistModel dentist, String token})> register(
    String name,
    String email,
    String password,
  ) async {
    return (
      dentist: DentistModel(id: 'd1', name: name, email: email),
      token: 'fake_jwt_token',
    );
  }

  @override
  Future<DentistModel> getMe() async {
    return DentistModel(id: 'd1', name: 'Dr. Test', email: 'test@example.com');
  }

  @override
  Future<String?> getToken() async => null;

  @override
  Future<void> saveToken(String token) async {}

  @override
  Future<void> logout() async {}
}

void main() {
  testWidgets('Dental Progress app renders login screen correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
        child: const DentalProgressApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify clinical app title and key interactive elements
    expect(find.text('Dental Progress'), findsWidgets);
    expect(find.text('Sign In to Clinical Portal'), findsOneWidget);
    expect(find.text('Dentist Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
