import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  /* ---------- PORT ---------- */
  static const int port = 3001;

  /* ---------- HOST ONLY (no port here) ---------- */
  static String get _host {
    if (kIsWeb) return 'localhost';

    // Android emulator
    return '10.0.2.2';
  }

  /* ---------- BASE URL ---------- */
  static String get baseUrl => 'http://$_host:$port';

  /* ---------- ROUTES ---------- */
  static const String signUp = '/api/auth/signup';
  static const String login  = '/api/auth/login';

  /* ---------- FULL URL HELPERS ---------- */
  static Uri get signUpUri => Uri.parse('$baseUrl$signUp');
  static Uri get loginUri  => Uri.parse('$baseUrl$login');
  static Uri get getUri => Uri.parse(baseUrl);
}
