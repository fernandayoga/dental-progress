import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/error_state_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/patient_avatar.dart';
import '../../../shared/widgets/status_badge.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardControllerProvider);

    if (dashboardState.isLoading && dashboardState.data == null) {
      return const Scaffold(body: LoadingView(message: 'Loading dashboard...'));
    }

    if (dashboardState.errorMessage != null && dashboardState.data == null) {
      return Scaffold(
        body: ErrorStateView(
          message: dashboardState.errorMessage!,
          onRetry: () => ref.read(dashboardControllerProvider.notifier).loadDashboard(),
        ),
      );
    }

    final data = dashboardState.data;
    final dentistName = data?.dentistName ?? 'Doctor';
    final totalPatients = data?.totalPatients ?? 0;
    final totalPhotos = data?.totalPhotos ?? 0;
    final recentPatients = data?.recentPatients ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dental Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Refresh',
            onPressed: () => ref.read(dashboardControllerProvider.notifier).loadDashboard(),
          ),
          const SizedBox(width: AppDimensions.sm),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.read(dashboardControllerProvider.notifier).loadDashboard(),
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.md),
          children: [
            // Clinical Greeting
            Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppDimensions.roundedMd,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dentistName,
                    style: AppTypography.pageTitle.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Clinical Practice Dashboard',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.md),

            // Statistics Summary Cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Patients',
                    count: totalPatients.toString(),
                    icon: Icons.people_outline,
                    onTap: () => context.go('/patients'),
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: _StatCard(
                    title: 'Progress Photos',
                    count: totalPhotos.toString(),
                    icon: Icons.photo_library_outlined,
                    onTap: () => context.go('/patients'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),

            // Quick Access Actions
            AppButton(
              label: 'Add New Patient',
              icon: Icons.person_add_alt_1_outlined,
              onPressed: () => context.push('/patients/add'),
              variant: AppButtonVariant.primary,
            ),
            const SizedBox(height: AppDimensions.lg),

            // Recently Added Patients Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recently Added Patients', style: AppTypography.sectionTitle),
                TextButton(
                  onPressed: () => context.go('/patients'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.xs),

            if (recentPatients.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(AppDimensions.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppDimensions.roundedMd,
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.folder_open_outlined, size: 36, color: AppColors.textTertiary),
                      const SizedBox(height: 8),
                      const Text(
                        'No patients registered yet',
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.push('/patients/add'),
                        child: const Text('Register First Patient'),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              ...recentPatients.map((patient) => Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.sm),
                    child: Card(
                      child: ListTile(
                        onTap: () => context.push('/patients/${patient.id}'),
                        leading: PatientAvatar(name: patient.name),
                        title: Text(
                          patient.name,
                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              patient.patientId,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            StatusBadge.gender(patient.gender),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (patient.photoCount > 0) ...[
                              const Icon(Icons.photo_outlined, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 3),
                              Text(
                                '${patient.photoCount}',
                                style: AppTypography.caption,
                              ),
                              const SizedBox(width: 6),
                            ],
                            const Icon(Icons.chevron_right, size: 18, color: AppColors.textTertiary),
                          ],
                        ),
                      ),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimensions.roundedMd,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppDimensions.roundedMd,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppTypography.label),
                Icon(icon, size: 18, color: AppColors.primary),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              count,
              style: AppTypography.pageTitle.copyWith(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
