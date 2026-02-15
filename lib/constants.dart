class ApiConfig {
  ApiConfig._();

  /// Public backend URL (Render)
  static const String _base = 'https://brain-note-backend.onrender.com/api';

  /* ---------- ROUTES ---------- */
  static const String google = '/auth/google';
  static const String user = '/user';
  static const String docs = '/docs';

  /// Full URL helpers
  static Uri get authUri => Uri.parse('$_base$google');
  static Uri get getUri => Uri.parse('$_base$user');
  static Uri get docUri => Uri.parse('$_base$docs');

}
