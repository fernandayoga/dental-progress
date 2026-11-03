import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: AppDimensions.roundedLg,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                size: 38,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            const Text(
              'Dental Progress',
              style: AppTypography.pageTitle,
            ),
            const SizedBox(height: AppDimensions.xs),
            const Text(
              'Orthodontic Documentation & Treatment Monitoring',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppDimensions.xl),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
