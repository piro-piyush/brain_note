import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// ===========================================================
/// Provider
/// ===========================================================
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final repo = AuthRepository(
    signIn: GoogleSignIn.instance,
  );
  ref.onDispose(repo.dispose);
  return repo;
});

/// ===========================================================
/// AuthRepository (google_sign_in v7+)
/// Handles:
/// • init
/// • silent login
/// • sign in
/// • access token
/// • logout
/// • auth events
/// ===========================================================
class AuthRepository {
  final GoogleSignIn _signIn;

  StreamSubscription<GoogleSignInAuthenticationEvent>? _authSub;

  static const _scopes = [
    'https://www.googleapis.com/auth/userinfo.email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ];

  /// 🔥 Constructor → auto initialize
  AuthRepository({required GoogleSignIn signIn,  })
    : _signIn = signIn;


  // ===========================================================
  // 🔹 SIGN IN (button click)
  // ===========================================================
  Future<GoogleSignInAccount?> signIn() async {
    try {
      debugPrint("🔵 Starting authenticate()");

      final account = await _signIn.authenticate(scopeHint: _scopes);

      debugPrint("✅ Account: ${account.email}");

      return account;
    } catch (e) {
      debugPrint("🔥 Error: $e");
      return null;
    }
  }

  // ===========================================================
  // 🔹 GET ACCESS TOKEN (backend/Supabase/Firebase)
  // ===========================================================
  Future<String?> getAccessToken(GoogleSignInAccount user) async {
    final auth = await user.authorizationClient.authorizationForScopes(_scopes);

    return auth?.accessToken;
  }

  // ===========================================================
  // 🔹 LOGOUT
  // ===========================================================
  Future<void> signOut() => _signIn.signOut();

  // ===========================================================
  // 🔹 CLEANUP
  // ===========================================================
  void dispose() => _authSub?.cancel();
}
