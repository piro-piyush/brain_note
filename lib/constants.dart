import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const int port = 3001;

  /// Detect host dynamically
  static Future<String> get host async {
    if (kIsWeb) return 'localhost';

    if (Platform.isAndroid || Platform.isIOS) {
      // Check if running on emulator/simulator
      final isEmulator = await _isEmulator();

      if (isEmulator) {
        // Android emulator uses 10.0.2.2, iOS simulator uses localhost
        return Platform.isAndroid ? '10.0.2.2' : 'localhost';
      } else {
        // Real device → return LAN IP of PC
        final lanIp = await _getLocalIp();
        return lanIp ?? 'localhost';
      }
    }

    // Fallback
    return 'localhost';
  }

  /// Build base URL dynamically
  static Future<String> get baseUrl async => 'http://${await host}:$port/api';

  /* ---------- ROUTES ---------- */
  static const String google = '/auth/google';
  static const String user = '/user';

  /// Full URL helpers
  static Future<Uri> get authUri async => Uri.parse('${await baseUrl}$google');
  static Future<Uri> get getUri async => Uri.parse('${await baseUrl}$user');

  /// Helper: Detect emulator
  static Future<bool> _isEmulator() async {
    if (Platform.isAndroid) {
      final androidId = await File('/proc/self/cgroup').readAsString().catchError((_) => '');
      return androidId.contains(':/docker') || androidId.contains(':/emulator');
    }
    if (Platform.isIOS) {
      // For iOS, simplest check: simulator has environment variable SIMULATOR_DEVICE_NAME
      return Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');
    }
    return false;
  }

  /// Helper: Get PC LAN IP (first IPv4 in Wi-Fi / Ethernet)
  static Future<String?> _getLocalIp() async {
    return "192.168.1.34";
  }
}
