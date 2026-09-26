class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';

  // Patients
  static const String patients = '/patients';
  static String patient(String id) => '/patients/$id';
  static String patientPhotos(String patientId) => '/patients/$patientId/photos';

  // Photos
  static String photo(String id) => '/photos/$id';

  // Dashboard
  static const String dashboardStats = '/dashboard/stats';
}
