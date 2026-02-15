class ApiConfig {
  ApiConfig._();

  /* ---------- HOSTS ---------- */

  static const String _prodHost =
      'https://brain-note-backend.onrender.com';

  static const String _devHost =
      'http://localhost:3001';

  /// Switch automatically if needed
  static String get host => _devHost;
  // static String get host => _prodHost;

  /* ---------- BASE PATH ---------- */

  static const String _apiPath = '/api';

  static String get base => '$host$_apiPath';

  /* ---------- ROUTES ---------- */

  static const String google = '/auth/google';
  static const String user = '/user';
  static const String createDoc = '/docs/create';
  static const String myDoc = '/docs/me';
  static const String changeTitle = '/docs/title';

  /* ---------- URI BUILDERS ---------- */

  static Uri get authUri => Uri.parse('$base$google');

  static Uri get userUri => Uri.parse('$base$user');

  static Uri get createDocUri => Uri.parse('$base$createDoc');

  static Uri get myDocUri => Uri.parse('$base$myDoc');

  static Uri get changeTitleUri => Uri.parse('$base$changeTitle');

  static Uri getDocUri(String id) =>
      Uri.parse('$base/docs/$id');
}
