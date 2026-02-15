import 'dart:async';
import 'dart:convert';
import 'package:brain_note/common/network/api_exception.dart';
import 'package:brain_note/common/network/status_handler.dart';
import 'package:brain_note/constants.dart';
import 'package:brain_note/models/error_model.dart';
import 'package:brain_note/models/user_model.dart';
import 'package:brain_note/repostiory/local_storage_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(
    clientId:
    '818686422862-1lme4ebsdbaflapqjl8vjj9543ha9bhc.apps.googleusercontent.com',
    serverClientId: kIsWeb
        ? null
        : '818686422862-1lme4ebsdbaflapqjl8vjj9543ha9bhc.apps.googleusercontent.com',
    scopes: const [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final repo = AuthRepository(
    signIn: ref.read(googleSignInProvider),
    client: Client(),
    storage: ref.read(localStorageProvider),
  );

  ref.onDispose(repo.dispose);
  return repo;
});

class UserNotifier extends Notifier<UserModel?> {
  @override
  UserModel? build() => null;

  void set(UserModel user) => state = user;

  void clear() => state = null;
}

final userProvider =
NotifierProvider<UserNotifier, UserModel?>(UserNotifier.new);

class AuthRepository {
  final GoogleSignIn _signIn;
  final Client _client;
  final LocalStorageRepository _storage;

  const AuthRepository({
    required GoogleSignIn signIn,
    required Client client,
    required LocalStorageRepository storage,
  })  : _signIn = signIn,
        _client = client,
        _storage = storage;

  // ==============================
  // 🔹 HEADERS
  // ==============================

  Map<String, String> _headers({String? token}) {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _persistToken(String token) =>
      _storage.setToken(token);

  ErrorModel _handleError(Object e, StackTrace stack) {
    if (e is ApiException) {
      return ErrorModel(error: e.message);
    }

    debugPrint('AuthRepository Error: $e');
    debugPrintStack(stackTrace: stack);

    return const ErrorModel(error: 'Something went wrong');
  }

  // ==============================
  // 🔹 SIGN IN
  // ==============================

  Future<ErrorModel> signIn() async {
    try {
      final account = await _signIn.signIn();
      if (account == null) {
        return const ErrorModel(error: 'Login cancelled');
      }

      final auth = await account.authentication;
      final token = kIsWeb ? auth.accessToken : auth.idToken;

      if (token == null) {
        return const ErrorModel(error: 'Failed to retrieve token');
      }

      final response = await _client.post(
        ApiConfig.authUri,
        headers: _headers(),
        body: jsonEncode({
          "token": token,
          "platform": kIsWeb ? "web" : "mobile",
        }),
      );

      final body = jsonDecode(response.body);
      StatusHandler.handle(response.statusCode, body);

      final user = UserModel.fromJson(body['data']['user'])
          .copyWith(token: body['data']['token']);

      await _persistToken(user.token);

      return ErrorModel(data: user);
    } catch (e, st) {
      return _handleError(e, st);
    }
  }

  // ==============================
  // 🔹 AUTO LOGIN
  // ==============================

  Future<ErrorModel> getUser() async {
    try {
      final token = _storage.getToken();
      if (token == null) {
        return const ErrorModel(error: 'No token found');
      }

      final response = await _client.get(
        ApiConfig.userUri,
        headers: _headers(token: token),
      );

      final body = jsonDecode(response.body);
      StatusHandler.handle(response.statusCode, body);

      final user = UserModel.fromJson(body['data']['user'])
          .copyWith(token: body['data']['token']);

      await _persistToken(user.token);

      return ErrorModel(data: user);
    } catch (e, st) {
      return _handleError(e, st);
    }
  }

  // ==============================
  // 🔹 LOGOUT
  // ==============================

  Future<void> signOut() async {
    await Future.wait([
      _signIn.signOut(),
      _signIn.disconnect(),
      _storage.clearToken(),
      _storage.clearAll(),
    ]);
  }

  // ==============================
  // 🔹 CLEANUP
  // ==============================

  void dispose() => _client.close();
}
