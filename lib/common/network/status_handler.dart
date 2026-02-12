import 'api_exception.dart';

class StatusHandler {
  static void handle(int statusCode, Map<String, dynamic> body) {
    final message = body['message'] ?? 'Something went wrong';

    switch (statusCode) {
      case 200:
      case 201:
        return;

      case 400:
        throw ApiException(message, statusCode);

      case 401:
        throw ApiException('Unauthorized login', statusCode);

      case 403:
        throw ApiException('Access denied', statusCode);

      case 404:
        throw ApiException('Not found', statusCode);

      case 409:
        throw ApiException(message, statusCode);

      case 500:
      default:
        throw ApiException('Server error', statusCode);
    }
  }
}
