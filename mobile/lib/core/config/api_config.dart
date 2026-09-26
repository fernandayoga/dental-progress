import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Base API URL with sensible platform default.
  /// Android emulator maps 10.0.2.2 to host's 127.0.0.1.
  /// Windows/macOS/Linux/Web can connect to 127.0.0.1 directly.
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:5000/api';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5000/api';
      }
    } catch (_) {
      // Platform may throw on web or unsupported targets
    }
    return 'http://127.0.0.1:5000/api';
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 30);
}
