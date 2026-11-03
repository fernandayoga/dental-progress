import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/error_state_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/patient_avatar.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../photos/presentation/photos_controller.dart';
import 'patients_controller.dart';

class PatientDetailScreen extends ConsumerStatefulWidget {
  final String patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  ConsumerState<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends ConsumerState<PatientDetailScreen> {
  Future<void> _handleDeletePatient(String patientName) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Patient Record?',
      message:
          'Are you sure you want to permanently delete $patientName and all associated orthodontic photos? This action cannot be undone.',
      confirmLabel: 'Delete Patient',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      final success = await ref
          .read(patientsControllerProvider.notifier)
          .deletePatient(widget.patientId);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient record and photos deleted.')),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientAsync = ref.watch(patientDetailProvider(widget.patientId));
    final photosState = ref.watch(patientPhotosControllerProvider(widget.patientId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Patient Record'),
        actions: [
          patientAsync.when(
            data: (patient) => PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (val) {
                if (val == 'edit') {
                  context.push('/patients/${patient.id}/edit', extra: patient).then((_) {
                    ref.invalidate(patientDetailProvider(widget.patientId));
                  });
                } else if (val == 'delete') {
                  _handleDeletePatient(patient.name);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Edit Patient Info'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Delete Patient', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: patientAsync.when(
        loading: () => const LoadingView(message: 'Loading patient records...'),
        error: (err, _) => ErrorStateView(
          message: err.toString(),
          onRetry: () => ref.invalidate(patientDetailProvider(widget.patientId)),
        ),
        data: (patient) {
          final photos = photosState.photos;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(patientDetailProvider(widget.patientId));
              await ref
                  .read(patientPhotosControllerProvider(widget.patientId).notifier)
                  .loadPhotos();
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.md,
                vertical: AppDimensions.md,
              ),
              children: [
                // Patient Identity & Info Strip (Compact Swiss Layout)
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
                      Row(
                        children: [
                          PatientAvatar(name: patient.name, size: 48),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patient.name,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: AppDimensions.roundedSm,
                                      ),
                                      child: Text(
                                        patient.patientId,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    StatusBadge.gender(patient.gender),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 10),

                      // Demographics row
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.cake_outlined, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Text(
                                  '${DateFormatter.format(patient.dateOfBirth)} (${DateFormatter.calculateAge(patient.dateOfBirth)})',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Text(
                                  patient.phone,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (patient.additionalInformation != null &&
                          patient.additionalInformation!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: AppDimensions.roundedSm,
                          ),
                          child: Text(
                            patient.additionalInformation!,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.35),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),

                // Treatment Photos Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Treatment Photos',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: AppDimensions.roundedSm,
                          ),
                          child: Text(
                            '${photos.length}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (photos.length >= 2) ...[
                      OutlinedButton.icon(
                        icon: const Icon(Icons.compare_arrows_rounded, size: 16),
                        label: const Text('Compare Progress', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 34),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary, width: 1.0),
                        ),
                        onPressed: () {
                          context.push(
                            '/photos/compare',
                            extra: {'patient': patient, 'photos': photos},
                          );
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppDimensions.sm),

                // Photo Gallery
                if (photosState.isLoading && photos.isEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(AppDimensions.xl),
                    child: LoadingView(message: 'Loading treatment photos...'),
                  ),
                ] else if (photos.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.xl),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppDimensions.roundedMd,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceMuted,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_a_photo_outlined,
                            size: 28,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        const Text(
                          'No Photos Documented Yet',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Capture and organize dental progress photos to track orthodontic alignment.',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.md),
                        AppButton(
                          label: 'Upload First Photo',
                          icon: Icons.camera_alt_outlined,
                          onPressed: () {
                            context.push(
                              '/patients/${patient.id}/photos/add',
                              extra: patient,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      final photo = photos[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppDimensions.roundedMd,
                          border: Border.all(color: AppColors.border),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            context.push(
                              '/photos/${photo.id}',
                              extra: {'photo': photo, 'patient': patient},
                            ).then((_) {
                              ref
                                  .read(patientPhotosControllerProvider(widget.patientId).notifier)
                                  .loadPhotos();
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Photo preview
                              Expanded(
                                child: CachedNetworkImage(
                                  imageUrl: photo.imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    color: AppColors.surfaceMuted,
                                    child: const Center(
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    color: AppColors.surfaceMuted,
                                    child: const Icon(
                                      Icons.broken_image_outlined,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ),
                              ),
                              // Metadata footer
                              Padding(
                                padding: const EdgeInsets.all(7.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        StatusBadge.category(photo.category),
                                        Text(
                                          DateFormatter.format(photo.documentationDate),
                                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                    if (photo.notes.isNotEmpty) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        photo.notes,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final patient = patientAsync.valueOrNull;
          if (patient != null) {
            context.push('/patients/${patient.id}/photos/add', extra: patient);
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_a_photo_rounded),
        label: const Text('Add Photo'),
      ),
    );
  }
}
