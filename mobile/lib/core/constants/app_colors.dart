import 'package:flutter/material.dart';

/// Design system color palette for Dental Progress
/// Follows modern clinical aesthetic: minimalist, calm, professional, trustworthy.
class AppColors {
  // Primary Clinical Palette
  static const Color primary = Color(0xFF007A87); // Professional medical teal
  static const Color primaryLight = Color(0xFFE0F2F1);
  static const Color primaryDark = Color(0xFF004D40);

  // Background & Surfaces
  static const Color background = Color(0xFFF8FAFC); // Very light cool gray
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9);

  // Typography / Text
  static const Color textPrimary = Color(0xFF0F172A); // Deep navy/charcoal
  static const Color textSecondary = Color(0xFF64748B); // Muted slate gray
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Status & Feedback
  static const Color success = Color(0xFF10B981); // Subtle healthcare green
  static const Color successLight = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B); // Soft amber
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFEF4444); // Muted red
  static const Color errorLight = Color(0xFFFEF2F2);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0); // Light neutral gray
  static const Color borderFocused = Color(0xFF007A87);

  // Patient Gender badges
  static const Color maleBadge = Color(0xFFE0F2FE);
  static const Color maleText = Color(0xFF0369A1);
  static const Color femaleBadge = Color(0xFFFCE7F3);
  static const Color femaleText = Color(0xFFBE185D);
}
