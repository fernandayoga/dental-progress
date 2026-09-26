import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _displayFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _inputFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, HH:mm');

  static String format(DateTime? date) {
    if (date == null) return '—';
    return _displayFormat.format(date);
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return '—';
    return _dateTimeFormat.format(date);
  }

  static String toIsoDateString(DateTime date) {
    return _inputFormat.format(date);
  }

  static DateTime? parse(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  static String calculateAge(DateTime? dob) {
    if (dob == null) return '';
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return '$age yrs';
  }
}
