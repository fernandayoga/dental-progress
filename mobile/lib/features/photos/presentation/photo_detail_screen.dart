import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../patients/domain/patient_model.dart';
import '../domain/photo_model.dart';
import 'photos_controller.dart';

class PhotoDetailScreen extends ConsumerStatefulWidget {
  final PhotoModel photo;
  final PatientModel? patient;

  const PhotoDetailScreen({
    super.key,
    required this.photo,
    this.patient,
  });

  @override
  ConsumerState<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends ConsumerState<PhotoDetailScreen> {
  late PhotoModel _currentPhoto;
  bool _isEditingNotes = false;
  late final TextEditingController _notesController;
  bool _isSavingNotes = false;

  @override
  void initState() {
    super.initState();
    _currentPhoto = widget.photo;
    _notesController = TextEditingController(text: _currentPhoto.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveNotes() async {
    setState(() => _isSavingNotes = true);
    try {
      final patientId = widget.patient?.id ?? _currentPhoto.patientId;
      final controller = ref.read(
        patientPhotosControllerProvider(patientId).notifier,
      );

      final updated = await controller.updatePhoto(
        _currentPhoto.id,
        notes: _notesController.text,
      );

      if (updated != null && mounted) {
        setState(() {
          _currentPhoto = updated;
          _isEditingNotes = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo notes updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update notes: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingNotes = false);
      }
    }
  }

  Future<void> _handleDeletePhoto() async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Photo?',
      message:
          'Are you sure you want to permanently delete this clinical photo? It will be removed from storage.',
      confirmLabel: 'Delete Photo',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      final patientId = widget.patient?.id ?? _currentPhoto.patientId;
      final success = await ref
          .read(patientPhotosControllerProvider(patientId).notifier)
          .deletePhoto(_currentPhoto.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo deleted successfully')),
        );
        context.pop();
      }
    }
  }

  void _openFullScreenViewer() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text(
              '${_currentPhoto.category} • ${DateFormatter.format(_currentPhoto.documentationDate)}',
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.0,
              child: CachedNetworkImage(
                imageUrl: _currentPhoto.imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Photo Inspection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.fullscreen_rounded),
            tooltip: 'Full Screen Zoom',
            onPressed: _openFullScreenViewer,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            tooltip: 'Delete Photo',
            onPressed: _handleDeletePhoto,
          ),
          const SizedBox(width: AppDimensions.xs),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dark Medical Inspection Viewport (Priority Focus)
            GestureDetector(
              onTap: _openFullScreenViewer,
              child: Container(
                height: 340,
                color: const Color(0xFF0F172A),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: CachedNetworkImage(
                        imageUrl: _currentPhoto.imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        ),
                        errorWidget: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image_rounded, color: Colors.white54, size: 48),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: AppDimensions.roundedSm,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.zoom_in_rounded, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Pinch to zoom / Tap fullscreen',
                              style: TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Metadata & Clinical Information
            Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges Row
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
                            StatusBadge.category(_currentPhoto.category),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: AppDimensions.roundedSm,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormatter.format(_currentPhoto.documentationDate),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (widget.patient != null) ...[
                          const SizedBox(height: AppDimensions.sm),
                          const Divider(height: 1),
                          const SizedBox(height: AppDimensions.sm),
                          Row(
                            children: [
                              const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                'Patient: ${widget.patient!.name} (${widget.patient!.patientId})',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),

                  // Clinical Observation Notes
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Clinical Notes',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            if (!_isEditingNotes)
                              TextButton.icon(
                                icon: const Icon(Icons.edit_outlined, size: 15),
                                label: const Text('Edit Notes'),
                                onPressed: () {
                                  setState(() {
                                    _notesController.text = _currentPhoto.notes;
                                    _isEditingNotes = true;
                                  });
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (_isEditingNotes) ...[
                          AppTextField(
                            controller: _notesController,
                            hint: 'Add or update clinical observation notes...',
                            maxLines: 4,
                            maxLength: 1000,
                            validator: Validators.note,
                          ),
                          const SizedBox(height: AppDimensions.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AppButton(
                                label: 'Cancel',
                                variant: AppButtonVariant.secondary,
                                onPressed: () {
                                  setState(() => _isEditingNotes = false);
                                },
                              ),
                              const SizedBox(width: AppDimensions.sm),
                              AppButton(
                                label: 'Save Notes',
                                variant: AppButtonVariant.primary,
                                isLoading: _isSavingNotes,
                                onPressed: _handleSaveNotes,
                              ),
                            ],
                          ),
                        ] else ...[
                          Text(
                            _currentPhoto.notes.isNotEmpty
                                ? _currentPhoto.notes
                                : 'No clinical observation notes recorded for this photo.',
                            style: TextStyle(
                              fontSize: 13,
                              color: _currentPhoto.notes.isNotEmpty
                                  ? AppColors.textPrimary
                                  : AppColors.textTertiary,
                              fontStyle: _currentPhoto.notes.isNotEmpty
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
