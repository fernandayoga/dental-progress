import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../auth/presentation/auth_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoggingOut = false;

  Future<void> _handleLogout() async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Log Out of Clinic Portal?',
      message: 'Are you sure you want to log out of Dental Progress?',
      confirmLabel: 'Log Out',
      isDestructive: true,
      onConfirm: () async {
        setState(() => _isLoggingOut = true);
        await ref.read(authControllerProvider.notifier).logout();
      },
    );

    if (confirmed && mounted) {
      context.go('/login');
    } else if (mounted) {
      setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final dentist = authState.dentist;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dentist Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.md,
        ),
        children: [
          // Practitioner Profile Card (Swiss minimal)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppDimensions.roundedMd,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      width: 1.0,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 30,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  dentist?.name ?? 'Dr. Dentist',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  dentist?.email ?? '',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: AppDimensions.roundedPill,
                  ),
                  child: const Text(
                    'LICENSED DENTAL PRACTITIONER',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.md),

          // Clinical Application Info (Grouped Surface)
          Container(
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppDimensions.roundedMd,
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SYSTEM INFRASTRUCTURE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.6,
                  ),
                ),
                SizedBox(height: AppDimensions.md),
                _ProfileRow(label: 'Application', value: 'Dental Progress'),
                Divider(height: 1),
                _ProfileRow(label: 'Platform Version', value: 'v1.0.0 (Production)'),
                Divider(height: 1),
                _ProfileRow(label: 'Image Storage', value: 'Cloudinary Encrypted'),
                Divider(height: 1),
                _ProfileRow(label: 'Database Cluster', value: 'MongoDB Atlas'),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.xl),

          // Logout Action
          AppButton(
            label: _isLoggingOut ? 'Logging Out...' : 'Log Out of Clinical Portal',
            variant: AppButtonVariant.danger,
            icon: Icons.logout_rounded,
            isLoading: _isLoggingOut,
            onPressed: _isLoggingOut ? null : _handleLogout,
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
