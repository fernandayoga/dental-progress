import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_typography.dart';

class AppSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const AppSearchBar({
    super.key,
    required this.controller,
    this.hint = 'Search patients by name or ID...',
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.roundedMd,
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                filled: false,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                if (onClear != null) {
                  onClear!();
                } else if (onChanged != null) {
                  onChanged!('');
                }
              },
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.close, size: 18, color: AppColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}
