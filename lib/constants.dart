class ApiConfig {
  ApiConfig._();

  /// Change automatically based on build mode
  static const String _prodBase = 'https://brain-note-backend.onrender.com/api';

  static const String _devBase =
      'http://10.0.2.2:3000/api'; // Android emulator localhost

  static String get _base =>
      // kReleaseMode ?
      _prodBase
  // : _devBase
  ;

  /* ---------- ROUTES ---------- */
  static const String google = '/auth/google';
  static const String user = '/user';
  static const String createDoc = '/docs/create';
  static const String myDoc = '/docs/me';
  static const String changeTitle = '/docs/title';

  /* ---------- URI BUILDERS ---------- */

  static Uri get authUri => Uri.parse('$_base$google');

  static Uri get userUri => Uri.parse('$_base$user');

  static Uri get createDocUri => Uri.parse('$_base$createDoc');

  static Uri get myDocUri => Uri.parse('$_base$myDoc');

  static Uri get changeTitleUri => Uri.parse('$_base$changeTitle');

  /// ✅ Correct dynamic path
  static Uri getDocUri(String id) => Uri.parse('$_base/docs/$id');
}
