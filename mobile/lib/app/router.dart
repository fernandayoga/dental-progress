import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/patients/domain/patient_model.dart';
import '../features/patients/presentation/add_edit_patient_screen.dart';
import '../features/patients/presentation/patient_detail_screen.dart';
import '../features/patients/presentation/patient_list_screen.dart';
import '../features/photos/domain/photo_model.dart';
import '../features/photos/presentation/add_photo_screen.dart';
import '../features/photos/presentation/photo_comparison_screen.dart';
import '../features/photos/presentation/photo_detail_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import 'scaffold_with_nav_bar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHome = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorPatients = GlobalKey<NavigatorState>(debugLabel: 'shellPatients');
final _shellNavigatorProfile = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isAuthenticating = authState.status == AuthStatus.authenticating;
      final isInitial = authState.status == AuthStatus.initial;
      if (isInitial || isAuthenticating) return null;

      final loggedIn = authState.isAuthenticated;
      final goingToLogin = state.matchedLocation == '/login';

      if (!loggedIn && !goingToLogin) {
        return '/login';
      }
      if (loggedIn && goingToLogin) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Branch Home / Dashboard
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHome,
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // Branch Patients
          StatefulShellBranch(
            navigatorKey: _shellNavigatorPatients,
            routes: [
              GoRoute(
                path: '/patients',
                builder: (context, state) => const PatientListScreen(),
              ),
            ],
          ),

          // Branch Profile
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfile,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Patient Workflow Routes (pushed on top of root navigator)
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/patients/add',
        builder: (context, state) => const AddEditPatientScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/patients/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PatientDetailScreen(patientId: id);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/patients/:id/edit',
        builder: (context, state) {
          final patient = state.extra as PatientModel?;
          return AddEditPatientScreen(initialPatient: patient);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/patients/:id/photos/add',
        builder: (context, state) {
          final patient = state.extra as PatientModel;
          return AddPhotoScreen(patient: patient);
        },
      ),

      // Photo Routes
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/photos/compare',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final patient = extra['patient'] as PatientModel;
          final photos = extra['photos'] as List<PhotoModel>;
          return PhotoComparisonScreen(
            patient: patient,
            photos: photos,
            initialPhotoA: extra['photoA'] as PhotoModel?,
            initialPhotoB: extra['photoB'] as PhotoModel?,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/photos/:id',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final photo = extra?['photo'] as PhotoModel;
          final patient = extra?['patient'] as PatientModel?;
          return PhotoDetailScreen(photo: photo, patient: patient);
        },
      ),
    ],
  );
});
