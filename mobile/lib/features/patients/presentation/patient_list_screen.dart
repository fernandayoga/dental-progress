import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/app_search_bar.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_state_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/patient_avatar.dart';
import '../../../shared/widgets/status_badge.dart';
import 'patients_controller.dart';

class PatientListScreen extends ConsumerStatefulWidget {
  const PatientListScreen({super.key});

  @override
  ConsumerState<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends ConsumerState<PatientListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(patientsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Patients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            tooltip: 'Add Patient',
            onPressed: () => context.push('/patients/add'),
          ),
          const SizedBox(width: AppDimensions.sm),
        ],
      ),
      body: Column(
        children: [
          // Prominent Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.md,
              AppDimensions.sm,
              AppDimensions.md,
              AppDimensions.sm,
            ),
            child: AppSearchBar(
              controller: _searchController,
              hint: 'Search by patient name or ID...',
              onChanged: (val) {
                ref.read(patientsControllerProvider.notifier).onSearchChanged(val);
              },
              onClear: () {
                ref.read(patientsControllerProvider.notifier).onSearchChanged('');
              },
            ),
          ),

          // Main Content List / States
          Expanded(
            child: Builder(
              builder: (context) {
                if (state.isLoading && state.patients.isEmpty) {
                  return const LoadingView(message: 'Searching patients...');
                }

                if (state.errorMessage != null && state.patients.isEmpty) {
                  return ErrorStateView(
                    message: state.errorMessage!,
                    onRetry: () => ref.read(patientsControllerProvider.notifier).loadPatients(),
                  );
                }

                if (state.patients.isEmpty) {
                  final isSearching = state.searchQuery.isNotEmpty;
                  return EmptyStateView(
                    icon: isSearching ? Icons.search_off_outlined : Icons.people_outline,
                    title: isSearching ? 'No Matching Patients' : 'No Patients Yet',
                    description: isSearching
                        ? 'No patient records found matching "${state.searchQuery}".'
                        : 'Register a new patient to begin orthodontic documentation.',
                    actionLabel: isSearching ? 'Clear Search' : 'Add First Patient',
                    onAction: () {
                      if (isSearching) {
                        _searchController.clear();
                        ref.read(patientsControllerProvider.notifier).onSearchChanged('');
                      } else {
                        context.push('/patients/add');
                      }
                    },
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => ref.read(patientsControllerProvider.notifier).loadPatients(),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.md,
                      vertical: AppDimensions.sm,
                    ),
                    itemCount: state.patients.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.sm),
                    itemBuilder: (context, index) {
                      final patient = state.patients[index];
                      return Card(
                        child: InkWell(
                          onTap: () => context.push('/patients/${patient.id}'),
                          borderRadius: AppDimensions.roundedMd,
                          child: Padding(
                            padding: const EdgeInsets.all(AppDimensions.md),
                            child: Row(
                              children: [
                                PatientAvatar(name: patient.name, size: 44),
                                const SizedBox(width: AppDimensions.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              patient.name,
                                              style: AppTypography.bodyMedium.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          StatusBadge.gender(patient.gender),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            patient.patientId,
                                            style: AppTypography.caption.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '•  ${DateFormatter.calculateAge(patient.dateOfBirth)}',
                                            style: AppTypography.caption,
                                          ),
                                        ],
                                      ),
                                      if (patient.latestDocumentationDate != null) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today_outlined,
                                              size: 11,
                                              color: AppColors.textTertiary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Latest doc: ${DateFormatter.format(patient.latestDocumentationDate)}',
                                              style: AppTypography.caption,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.sm),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (patient.photoCount > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceMuted,
                                          borderRadius: AppDimensions.roundedSm,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.photo_outlined, size: 12, color: AppColors.textSecondary),
                                            const SizedBox(width: 3),
                                            Text(
                                              '${patient.photoCount}',
                                              style: AppTypography.caption.copyWith(
                                                color: AppColors.textSecondary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(height: 6),
                                    const Icon(
                                      Icons.chevron_right,
                                      size: 18,
                                      color: AppColors.textTertiary,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/patients/add'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        tooltip: 'Add Patient',
        child: const Icon(Icons.add),
      ),
    );
  }
}
