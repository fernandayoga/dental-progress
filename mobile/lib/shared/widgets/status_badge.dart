import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_typography.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  factory StatusBadge.gender(String gender) {
    if (gender.toLowerCase() == 'male') {
      return const StatusBadge(
        label: 'Male',
        backgroundColor: AppColors.maleBadge,
        textColor: AppColors.maleText,
      );
    } else if (gender.toLowerCase() == 'female') {
      return const StatusBadge(
        label: 'Female',
        backgroundColor: AppColors.femaleBadge,
        textColor: AppColors.femaleText,
      );
    }
    return const StatusBadge(
      label: 'Other',
      backgroundColor: AppColors.surfaceMuted,
      textColor: AppColors.textSecondary,
    );
  }

  factory StatusBadge.category(String category) {
    return StatusBadge(
      label: category,
      backgroundColor: AppColors.primaryLight,
      textColor: AppColors.primaryDark,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppDimensions.roundedSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
