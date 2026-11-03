import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../domain/patient_model.dart';
import 'patients_controller.dart';

class AddEditPatientScreen extends ConsumerStatefulWidget {
  final PatientModel? initialPatient;

  const AddEditPatientScreen({super.key, this.initialPatient});

  @override
  ConsumerState<AddEditPatientScreen> createState() => _AddEditPatientScreenState();
}

class _AddEditPatientScreenState extends ConsumerState<AddEditPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _additionalInfoController;
  late final TextEditingController _dobController;

  DateTime? _selectedDob;
  String _selectedGender = 'Male';
  bool _isSaving = false;

  bool get _isEditing => widget.initialPatient != null;

  @override
  void initState() {
    super.initState();
    final patient = widget.initialPatient;
    _nameController = TextEditingController(text: patient?.name ?? '');
    _phoneController = TextEditingController(text: patient?.phone ?? '');
    _additionalInfoController = TextEditingController(text: patient?.additionalInformation ?? '');
    _selectedDob = patient?.dateOfBirth;
    _dobController = TextEditingController(
      text: _selectedDob != null ? DateFormatter.format(_selectedDob) : '',
    );
    _selectedGender = patient?.gender ?? 'Male';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _additionalInfoController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final initial = _selectedDob ?? DateTime(now.year - 20, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
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
        _selectedDob = picked;
        _dobController.text = DateFormatter.format(picked);
      });
    }
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select patient date of birth.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final controller = ref.read(patientsControllerProvider.notifier);

      if (_isEditing) {
        await controller.updatePatient(
          id: widget.initialPatient!.id,
          name: _nameController.text,
          dateOfBirth: _selectedDob!,
          gender: _selectedGender,
          phone: _phoneController.text,
          additionalInformation: _additionalInfoController.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Patient updated successfully')),
          );
          context.pop(true);
        }
      } else {
        final newPatient = await controller.createPatient(
          name: _nameController.text,
          dateOfBirth: _selectedDob!,
          gender: _selectedGender,
          phone: _phoneController.text,
          additionalInformation: _additionalInfoController.text,
        );
        if (mounted && newPatient != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Patient ${newPatient.name} registered (${newPatient.patientId})')),
          );
          context.pushReplacement('/patients/${newPatient.id}');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving patient: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Patient Record' : 'Register Patient'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.md,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Single cohesive Swiss Form Container
              Container(
                padding: const EdgeInsets.all(AppDimensions.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppDimensions.roundedMd,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Subtitle
                    Text(
                      _isEditing
                          ? 'Editing record for ${widget.initialPatient!.patientId}'
                          : 'Enter demographic and clinical details to register a new orthodontic patient.',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
                    ),
                    const SizedBox(height: AppDimensions.lg),

                    // SECTION 1: PERSONAL INFORMATION
                    const Text(
                      'PERSONAL INFORMATION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.md),

                    // Full Name
                    AppTextField(
                      label: 'Full Name',
                      hint: 'e.g. Eleanor Vance',
                      controller: _nameController,
                      validator: (val) => Validators.required(val, 'Patient name'),
                      isRequired: true,
                      prefixIcon: const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppDimensions.md),

                    // Date of Birth
                    AppTextField(
                      label: 'Date of Birth',
                      hint: 'Select date of birth',
                      controller: _dobController,
                      readOnly: true,
                      onTap: _pickDateOfBirth,
                      validator: (val) => Validators.required(val, 'Date of birth'),
                      isRequired: true,
                      prefixIcon: const Icon(Icons.cake_outlined, size: 18, color: AppColors.textSecondary),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_month_outlined, size: 18, color: AppColors.primary),
                        onPressed: _pickDateOfBirth,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.md),

                    // Gender Selector
                    const Text('Gender *', style: AppTypography.label),
                    const SizedBox(height: AppDimensions.xs + 2),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'Male', label: Text('Male')),
                        ButtonSegment(value: 'Female', label: Text('Female')),
                        ButtonSegment(value: 'Other', label: Text('Other')),
                      ],
                      selected: {_selectedGender},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _selectedGender = newSelection.first;
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                          (states) {
                            if (states.contains(WidgetState.selected)) {
                              return AppColors.primaryLight;
                            }
                            return AppColors.surface;
                          },
                        ),
                        foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                          (states) {
                            if (states.contains(WidgetState.selected)) {
                              return AppColors.primaryDark;
                            }
                            return AppColors.textSecondary;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    const Divider(height: 1),
                    const SizedBox(height: AppDimensions.lg),

                    // SECTION 2: CONTACT & CLINICAL RECORD
                    const Text(
                      'CONTACT & CLINICAL OBSERVATIONS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.md),

                    // Phone Number
                    AppTextField(
                      label: 'Phone Number',
                      hint: 'e.g. +1 555-019-2834',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: Validators.phone,
                      isRequired: true,
                      prefixIcon: const Icon(Icons.phone_outlined, size: 18, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppDimensions.md),

                    // Optional Notes
                    AppTextField(
                      label: 'Clinical Notes / Diagnosis (Optional)',
                      hint: 'e.g. Malocclusion Class II, anterior crowding, crossbite notes...',
                      controller: _additionalInfoController,
                      maxLines: 4,
                      maxLength: 1000,
                      validator: Validators.note,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.lg),

              // Form Actions
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
                      label: _isEditing ? 'Save Changes' : 'Register Patient',
                      variant: AppButtonVariant.primary,
                      isLoading: _isSaving,
                      onPressed: _savePatient,
                      icon: _isEditing ? Icons.check_rounded : Icons.person_add_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.lg),
            ],
          ),
        ),
      ),
    );
  }
}
