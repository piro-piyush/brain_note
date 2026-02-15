import 'dart:convert';

import 'package:brain_note/common/network/api_exception.dart';
import 'package:brain_note/common/network/status_handler.dart';
import 'package:brain_note/constants.dart';
import 'package:brain_note/models/document_model.dart';
import 'package:brain_note/models/error_model.dart';
import 'package:brain_note/repostiory/local_storage_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

final docsRepositoryProvider = Provider<DocumentRepository>((ref) {
  final repo = DocumentRepository(
    client: Client(),
    storage: ref.read(localStorageProvider),
  );

  ref.onDispose(repo.dispose);
  return repo;
});

class DocumentRepository {
  final Client _client;
  final LocalStorageRepository _storage;

  DocumentRepository({
    required Client client,
    required LocalStorageRepository storage,
  }) : _client = client,
       _storage = storage;

  void dispose() => _client.close();

  Map<String, String> _headers({String? token}) {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<ErrorModel> createDocument() async {
    try {
      final token = _storage.getToken();
      if (token == null) {
        return const ErrorModel(error: 'No token found');
      }

      final response = await _client.post(
        ApiConfig.createDocUri,
        headers: _headers(token: token),
        body: jsonEncode({"createdAt": DateTime.now().millisecondsSinceEpoch}),
      );

      final body = jsonDecode(response.body);
      StatusHandler.handle(response.statusCode, body);

      final document = DocumentModel.fromJson(body['data']);
      return ErrorModel(data: document);
    } catch (e, st) {
      return _handleError(e, st);
    }
  }

  ErrorModel _handleError(Object e, StackTrace stack) {
    if (e is ApiException) {
      return ErrorModel(error: e.message);
    }

    debugPrint('DocsRepository Error: $e');
    debugPrintStack(stackTrace: stack);

    return const ErrorModel(error: 'Something went wrong');
  }
}
