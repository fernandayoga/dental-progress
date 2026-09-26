import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
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
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Patient Identification Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppDimensions.roundedMd,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Patient: ${widget.patient.name} (${widget.patient.patientId})',
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.md),

            // Image Capture / Picker Area
            if (_fileBytes == null) ...[
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppDimensions.roundedMd,
                  border: Border.all(
                    color: AppColors.border,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    const Text(
                      'Select Dental Clinical Photo',
                      style: AppTypography.sectionTitle,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Supports JPG, PNG, WEBP (up to 10MB)',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: AppDimensions.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppButton(
                          label: 'Camera',
                          icon: Icons.camera_alt_outlined,
                          variant: AppButtonVariant.primary,
                          onPressed: () => _pickImage(ImageSource.camera),
                        ),
                        const SizedBox(width: AppDimensions.md),
                        AppButton(
                          label: 'Gallery',
                          icon: Icons.photo_library_outlined,
                          variant: AppButtonVariant.secondary,
                          onPressed: () => _pickImage(ImageSource.gallery),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Image Preview Card
              Container(
                height: 260,
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
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: AppDimensions.roundedSm,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                              tooltip: 'Retake / Choose Another',
                              onPressed: () => _pickImage(ImageSource.gallery),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white, size: 20),
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

            // Documentation Date Picker
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppDimensions.roundedMd,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_outlined, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Date of Documentation', style: AppTypography.label),
                        const SizedBox(height: 2),
                        Text(
                          DateFormatter.format(_documentationDate),
                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDocumentationDate,
                    child: const Text('Change Date'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.md),

            // Category Chips Selector
            const Text('Photo Category', style: AppTypography.label),
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
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimensions.md),

            // Clinical Notes Field
            AppTextField(
              label: 'Clinical Notes (Optional)',
              hint: 'e.g. Incisor leveling progress, aligner stage 5 check, rotation corrected...',
              controller: _notesController,
              maxLines: 4,
              maxLength: 1000,
              validator: Validators.note,
            ),
            const SizedBox(height: AppDimensions.lg),

            // Upload / Cancel Buttons
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
          ],
        ),
      ),
    );
  }
}
