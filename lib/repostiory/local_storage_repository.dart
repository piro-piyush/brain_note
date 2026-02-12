import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localStorageProvider = Provider<LocalStorageRepository>((ref) {
  throw UnimplementedError(); // overridden in main
});

class LocalStorageRepository {
  final SharedPreferences _prefs;

  static const _tokenKey = 'x-auth-token';

  LocalStorageRepository(this._prefs);

  /* =========================
     SAVE TOKEN
  ========================= */
  Future<void> setToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  /* =========================
     GET TOKEN
  ========================= */
  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  /* =========================
     REMOVE TOKEN
  ========================= */
  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
  }

  /* =========================
     CLEAR ALL
  ========================= */
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
