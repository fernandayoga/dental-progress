import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'dentist@dentalprogress.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).login(
          _emailController.text,
          _passwordController.text,
        );

    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.status == AuthStatus.authenticating;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Icon & Clinical Header
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: AppDimensions.roundedMd,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.medical_services_outlined,
                          size: 34,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.md),
                    const Text(
                      'Dental Progress',
                      textAlign: TextAlign.center,
                      style: AppTypography.pageTitle,
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    const Text(
                      'Orthodontic Documentation & Treatment Monitoring',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: AppDimensions.xl),

                    // Error Banner if login fails
                    if (authState.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.md),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: AppDimensions.roundedMd,
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                            const SizedBox(width: AppDimensions.sm),
                            Expanded(
                              child: Text(
                                authState.errorMessage!,
                                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.md),
                    ],

                    // Email Field
                    AppTextField(
                      label: 'Dentist Email',
                      hint: 'dentist@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined, size: 20, color: AppColors.textSecondary),
                      validator: Validators.email,
                      isRequired: true,
                    ),
                    const SizedBox(height: AppDimensions.md),

                    // Password Field
                    AppTextField(
                      label: 'Password',
                      hint: 'Enter your password',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppColors.textSecondary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: Validators.password,
                      isRequired: true,
                    ),
                    const SizedBox(height: AppDimensions.lg),

                    // Sign In Button
                    AppButton(
                      label: 'Sign In to Clinical Portal',
                      onPressed: _handleLogin,
                      isLoading: isLoading,
                      variant: AppButtonVariant.primary,
                      icon: Icons.login,
                    ),
                    const SizedBox(height: AppDimensions.md),

                    // Quick Demo Credentials Hint
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: AppDimensions.roundedSm,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Default Demo: dentist@dentalprogress.com / password123',
                              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
