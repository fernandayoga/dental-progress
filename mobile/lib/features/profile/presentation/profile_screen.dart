import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../auth/presentation/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final dentist = authState.dentist;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dentist Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.md),
        children: [
          // Profile Card
          Container(
            padding: const EdgeInsets.all(AppDimensions.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppDimensions.roundedMd,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 36,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  dentist?.name ?? 'Dr. Dentist',
                  style: AppTypography.pageTitle.copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  dentist?.email ?? '',
                  style: AppTypography.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.md),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: AppDimensions.roundedSm,
                  ),
                  child: Text(
                    'Licensed Dental Practitioner',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.md),

          // Practice & System Info Card
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
                const Text('Clinical Application Info', style: AppTypography.sectionTitle),
                const SizedBox(height: AppDimensions.md),
                _ProfileRow(label: 'Application', value: 'Dental Progress'),
                const Divider(),
                _ProfileRow(label: 'Platform Version', value: 'v1.0.0 (Production)'),
                const Divider(),
                _ProfileRow(label: 'Image Storage', value: 'Cloudinary Encrypted'),
                const Divider(),
                _ProfileRow(label: 'Database', value: 'MongoDB Cloud/Local Cluster'),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.xl),

          // Logout Action
          AppButton(
            label: 'Log Out of Clinical Portal',
            variant: AppButtonVariant.danger,
            icon: Icons.logout,
            onPressed: () async {
              final confirmed = await ConfirmDialog.show(
                context: context,
                title: 'Log Out?',
                message: 'Are you sure you want to log out of Dental Progress?',
                confirmLabel: 'Log Out',
                isDestructive: true,
              );

              if (confirmed) {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
