import 'package:flutter/material.dart';

class AppDimensions {
  // Spacing
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;

  // Corner Radii (subtle, clean, not excessively rounded)
  static const double radiusSm = 6.0;
  static const double radiusMd = 10.0;
  static const double radiusLg = 14.0;

  // Border radius objects
  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(radiusLg));

  // Minimum Touch Target
  static const double minTouchTarget = 48.0;

  // App Bar Height
  static const double appBarHeight = 56.0;
}
