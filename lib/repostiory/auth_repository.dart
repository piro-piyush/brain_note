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
    webClientId:
    '818686422862-0g0msec5o2rs5gh2lfn9aiek63dutpoj.apps.googleusercontent.com',
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
  final String _webClientId;

  StreamSubscription<GoogleSignInAuthenticationEvent>? _authSub;

  static const _scopes = [
    'https://www.googleapis.com/auth/userinfo.email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ];

  /// 🔥 Constructor → auto initialize
  AuthRepository({
    required GoogleSignIn signIn,
    required String webClientId,
  })  : _signIn = signIn,
        _webClientId = webClientId {
    _init(); // auto start
  }

  // ===========================================================
  // 🔹 INIT (private)
  // ===========================================================
  Future<void> _init() async {
    /// 🔥 IMPORTANT:
    /// Web → serverClientId NOT supported
    /// Mobile → required sometimes
    await _signIn.initialize(
      clientId: _webClientId,
      serverClientId: kIsWeb ? null : _webClientId,
    );

    _authSub = _signIn.authenticationEvents.listen(_onAuthEvent);

    /// restore previous session automatically
    await _signIn.attemptLightweightAuthentication();
  }

  // ===========================================================
  // 🔹 AUTH EVENTS
  // ===========================================================
  void _onAuthEvent(GoogleSignInAuthenticationEvent event) {
    print('Auth event: $event');
  }

  // ===========================================================
  // 🔹 SIGN IN (button click)
  // ===========================================================
  Future<GoogleSignInAccount?> signIn() async {
    if (!_signIn.supportsAuthenticate()) return null;

    return _signIn.authenticate(scopeHint: _scopes);
  }

  // ===========================================================
  // 🔹 GET ACCESS TOKEN (backend/Supabase/Firebase)
  // ===========================================================
  Future<String?> getAccessToken(GoogleSignInAccount user) async {
    final auth =
    await user.authorizationClient.authorizationForScopes(_scopes);

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
