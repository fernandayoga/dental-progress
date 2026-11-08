import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
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
        title: Row(
          children: [
            const Text('Patients'),
            if (state.patients.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: AppDimensions.roundedSm,
                ),
                child: Text(
                  '${state.patients.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            tooltip: 'Add Patient',
            onPressed: () => context.push('/patients/add'),
          ),
          const SizedBox(width: AppDimensions.xs),
        ],
      ),
      body: Column(
        children: [
          // Minimalist Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.md,
              AppDimensions.sm,
              AppDimensions.md,
              AppDimensions.xs,
            ),
            child: AppSearchBar(
              controller: _searchController,
              hint: 'Search patients by name or ID...',
              onChanged: (val) {
                ref.read(patientsControllerProvider.notifier).onSearchChanged(val);
              },
              onClear: () {
                ref.read(patientsControllerProvider.notifier).onSearchChanged('');
              },
            ),
          ),

          // Active Query / Filter Feedback
          if (state.searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.md,
                vertical: AppDimensions.xs,
              ),
              child: Row(
                children: [
                  Text(
                    '${state.patients.length} results for "${state.searchQuery}"',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      ref.read(patientsControllerProvider.notifier).onSearchChanged('');
                    },
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Main Patient Content
          Expanded(
            child: Builder(
              builder: (context) {
                if (state.isLoading && state.patients.isEmpty) {
                  return const LoadingView(message: 'Loading patient records...');
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
                    icon: isSearching ? Icons.search_off_rounded : Icons.people_outline_rounded,
                    title: isSearching ? 'No Matching Patients' : 'No Patients Yet',
                    description: isSearching
                        ? 'No patient records found matching "${state.searchQuery}".'
                        : 'Register a patient to begin orthodontic treatment documentation.',
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
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.md,
                      vertical: AppDimensions.sm,
                    ),
                    children: [
                      // Cohesive Grouped Surface with subtle dividers (No individual heavy cards!)
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppDimensions.roundedMd,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            for (int i = 0; i < state.patients.length; i++) ...[
                              InkWell(
                                onTap: () => context.push('/patients/${state.patients[i].id}'),
                                borderRadius: i == 0
                                    ? const BorderRadius.vertical(top: Radius.circular(12))
                                    : (i == state.patients.length - 1
                                        ? const BorderRadius.vertical(bottom: Radius.circular(12))
                                        : BorderRadius.zero),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  child: Row(
                                    children: [
                                      PatientAvatar(name: state.patients[i].name, size: 40),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    state.patients[i].name,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.textPrimary,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                StatusBadge.gender(state.patients[i].gender),
                                              ],
                                            ),
                                            const SizedBox(height: 3),
                                            Row(
                                              children: [
                                                Text(
                                                  state.patients[i].patientId,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '•  ${DateFormatter.calculateAge(state.patients[i].dateOfBirth)}',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (state.patients[i].latestDocumentationDate != null) ...[
                                              const SizedBox(height: 3),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.calendar_today_outlined,
                                                    size: 11,
                                                    color: AppColors.textTertiary,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Latest: ${DateFormatter.format(state.patients[i].latestDocumentationDate)}',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: AppColors.textTertiary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          if (state.patients[i].photoCount > 0)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryLight,
                                                borderRadius: AppDimensions.roundedSm,
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.photo_library_outlined, size: 11, color: AppColors.primaryDark),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    '${state.patients[i].photoCount}',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.primaryDark,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          const SizedBox(height: 4),
                                          const Icon(
                                            Icons.chevron_right_rounded,
                                            size: 18,
                                            color: AppColors.textTertiary,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (i < state.patients.length - 1)
                                const Divider(height: 1, indent: 64, color: AppColors.border),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 80), // Fab scroll padding
                    ],
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
        child: const Icon(Icons.person_add_rounded),
      ),
    );
  }
}
