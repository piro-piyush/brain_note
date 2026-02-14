import 'dart:async';
import 'dart:convert';

import 'package:brain_note/models/error_model.dart';
import 'package:brain_note/repostiory/local_storage_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/network/api_exception.dart';
import '../../common/network/status_handler.dart';
import '../../constants.dart';
import '../../models/user_model.dart';

/// ===========================================================
/// Repository Provider
/// ===========================================================

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final localStorageRepository = ref.read(localStorageProvider);
  final repo = AuthRepository(
    signIn: GoogleSignIn(
      clientId:
          '818686422862-1lme4ebsdbaflapqjl8vjj9543ha9bhc.apps.googleusercontent.com',
      serverClientId: kIsWeb
          ? null
          : '818686422862-1lme4ebsdbaflapqjl8vjj9543ha9bhc.apps.googleusercontent.com',
      scopes: [
        'https://www.googleapis.com/auth/userinfo.email',
        'https://www.googleapis.com/auth/userinfo.profile',
      ],
    ),
    client: Client(),
    localStorageRepository: localStorageRepository,
  );

  ref.onDispose(repo.dispose);
  return repo;
});

/// ===========================================================
/// ✅ USER STATE (Riverpod 3.x style)
/// ===========================================================

class UserNotifier extends Notifier<UserModel?> {
  @override
  UserModel? build() => null;

  void setUser(UserModel user) => state = user;

  void clear() => state = null;
}

final userProvider = NotifierProvider<UserNotifier, UserModel?>(
  UserNotifier.new,
);

/// ===========================================================
/// AuthRepository
/// ===========================================================

class AuthRepository {
  final GoogleSignIn _signIn;
  final Client _client;
  final LocalStorageRepository _storage;

  AuthRepository({
    required GoogleSignIn signIn,
    required Client client,
    required LocalStorageRepository localStorageRepository,
  }) : _signIn = signIn,
       _client = client,
       _storage = localStorageRepository;

  // ===========================================================
  // 🔹 COMMON HELPERS
  // ===========================================================

  Future<Map<String, String>> _authHeaders() async {
    final token = _storage.getToken();

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _saveToken(String token) => _storage.setToken(token);

  ErrorModel _handleError(Object e, StackTrace stack) {
    if (e is ApiException) {
      return ErrorModel(error: e.message, data: null);
    }
    debugPrint("$stack");
    debugPrint("🔥 Auth error: $e");
    return const ErrorModel(error: "Something went wrong", data: null);
  }

  // ===========================================================
  // 🔹 SIGN IN
  // ===========================================================

  Future<ErrorModel> signIn() async {
    try {
      final account = await _signIn.signIn();
      if (account == null) return ErrorModel(error: "Login cancelled");

      final auth = await account.authentication;

      // Send idToken on mobile, accessToken on web
      final tokenToSend = !kIsWeb ? auth.idToken : auth.accessToken;
      if (tokenToSend == null) return ErrorModel(error: "Failed to get token");

      final platform = kIsWeb ? "web" : "mobile";
      final response = await _client.post(
        ApiConfig.authUri,
        headers: const {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({"token": tokenToSend, "platform": platform}),
      );

      final body = jsonDecode(response.body);
      StatusHandler.handle(response.statusCode, body);

      final user = UserModel.fromJson(
        body['data']['user'],
      ).copyWith(token: body['data']['token']);

      await _saveToken(user.token);

      return ErrorModel(data: user);
    } catch (e, st) {
      return _handleError(e, st);
    }
  }

  // ===========================================================
  // 🔹 AUTO LOGIN (token based)
  // ===========================================================

  Future<ErrorModel> getUser() async {
    try {
      final headers = await _authHeaders();

      if (!headers.containsKey('Authorization')) {
        return const ErrorModel(error: "No token found", data: null);
      }

      final response = await _client.get(ApiConfig.getUri, headers: headers);

      final body = jsonDecode(response.body);

      StatusHandler.handle(response.statusCode, body);

      final user = UserModel.fromJson(
        body['data']['user'],
      ).copyWith(token: body['data']['token']);

      await _saveToken(user.token);

      return ErrorModel(data: user);
    } catch (e, st) {
      return _handleError(e, st);
    }
  }

  // ===========================================================
  // 🔹 LOGOUT
  // ===========================================================

  Future<void> signOut() async {
    Future.wait([_signIn.signOut(), _signIn.disconnect()]);
  }

  // ===========================================================
  // 🔹 CLEANUP
  // ===========================================================

  void dispose() => _client.close();
}
