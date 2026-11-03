import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/patient_avatar.dart';
import '../../patients/domain/patient_model.dart';
import 'photos_controller.dart';

class AddPhotoScreen extends ConsumerStatefulWidget {
  final PatientModel patient;

  const AddPhotoScreen({super.key, required this.patient});

  @override
  ConsumerState<AddPhotoScreen> createState() => _AddPhotoScreenState();
}

class _AddPhotoScreenState extends ConsumerState<AddPhotoScreen> {
  final _notesController = TextEditingController();
  final _picker = ImagePicker();

  XFile? _selectedFile;
  Uint8List? _fileBytes;
  DateTime _documentationDate = DateTime.now();
  String _selectedCategory = 'Frontal Smile';
  bool _isUploading = false;

  final List<String> _categories = [
    'Frontal Smile',
    'Upper Occlusal',
    'Lower Occlusal',
    'Right Lateral',
    'Left Lateral',
    'Panoramic X-Ray',
    'Cephalometric',
    'Other',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );

      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _selectedFile = file;
          _fileBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accessing camera/gallery: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickDocumentationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _documentationDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _documentationDate = picked;
      });
    }
  }

  Future<void> _uploadPhoto() async {
    if (_selectedFile == null || _fileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or capture a photo first.')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final controller = ref.read(
        patientPhotosControllerProvider(widget.patient.id).notifier,
      );

      await controller.uploadPhoto(
        filePath: kIsWeb ? null : _selectedFile!.path,
        fileBytes: _fileBytes,
        fileName: _selectedFile!.name.isNotEmpty
            ? _selectedFile!.name
            : 'dental_photo.jpg',
        category: _selectedCategory,
        documentationDate: _documentationDate,
        notes: _notesController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dental photo uploaded successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Progress Photo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Patient Identification Context Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppDimensions.roundedMd,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  PatientAvatar(name: widget.patient.name, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.patient.name,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        Text(
                          'Patient ID: ${widget.patient.patientId}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.md),

            // HERO: Image-First Capture / Preview Viewport
            if (_fileBytes == null) ...[
              Container(
                height: 230,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppDimensions.roundedMd,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: AppDimensions.roundedSm,
                      ),
                      child: const Icon(
                        Icons.add_a_photo_rounded,
                        size: 30,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    const Text(
                      'Capture or Upload Dental Photo',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'High-resolution clinical alignment photo',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppDimensions.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppButton(
                          label: 'Camera',
                          icon: Icons.camera_alt_rounded,
                          variant: AppButtonVariant.primary,
                          onPressed: () => _pickImage(ImageSource.camera),
                        ),
                        const SizedBox(width: AppDimensions.md),
                        AppButton(
                          label: 'Gallery',
                          icon: Icons.photo_library_rounded,
                          variant: AppButtonVariant.secondary,
                          onPressed: () => _pickImage(ImageSource.gallery),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Image Preview Viewport (Visual Hero)
              Container(
                height: 270,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: AppDimensions.roundedMd,
                  border: Border.all(color: AppColors.border),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(_fileBytes!, fit: BoxFit.contain),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: AppDimensions.roundedSm,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                              tooltip: 'Retake',
                              onPressed: () => _pickImage(ImageSource.gallery),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                              tooltip: 'Remove',
                              onPressed: () {
                                setState(() {
                                  _selectedFile = null;
                                  _fileBytes = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.md),

            // Photo Metadata & Observations Container
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
                  // Documentation Date Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('DOCUMENTATION DATE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5)),
                          const SizedBox(height: 3),
                          Text(
                            DateFormatter.format(_documentationDate),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_month_outlined, size: 16),
                        label: const Text('Change Date'),
                        onPressed: _pickDocumentationDate,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.md),
                  const Divider(height: 1),
                  const SizedBox(height: AppDimensions.md),

                  // Photo Category Chips
                  const Text('PHOTO CATEGORY *', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5)),
                  const SizedBox(height: AppDimensions.xs + 2),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = cat);
                          }
                        },
                        selectedColor: AppColors.primaryLight,
                        backgroundColor: AppColors.surfaceMuted,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 11,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppDimensions.md),

                  // Clinical Notes
                  AppTextField(
                    label: 'Clinical Observation Notes (Optional)',
                    hint: 'e.g. Incisor alignment progress, aligner stage 5 check, rotation corrected...',
                    controller: _notesController,
                    maxLines: 4,
                    maxLength: 1000,
                    validator: Validators.note,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Cancel',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => context.pop(),
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: AppButton(
                    label: 'Upload Photo',
                    variant: AppButtonVariant.primary,
                    isLoading: _isUploading,
                    onPressed: _uploadPhoto,
                    icon: Icons.cloud_upload_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.lg),
          ],
        ),
      ),
    );
  }
}
