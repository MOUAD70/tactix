/// Custom exceptions thrown by the API client and data layer.
///
/// These exceptions are used to map HTTP status codes into meaningful types
/// that can be handled by UI layer.
library;

class ApiException implements Exception {
  ApiException(this.message, {this.errors});

  final String message;
  final Map<String, dynamic>? errors;

  @override
  String toString() => 'ApiException(message: $message, errors: $errors)';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([super.message = 'Unauthorized']);
}

class ForbiddenException extends ApiException {
  ForbiddenException([super.message = 'Forbidden']);
}

class NotFoundException extends ApiException {
  NotFoundException([super.message = 'Not found']);
}

class ValidationException extends ApiException {
  ValidationException(super.message, {super.errors});
}

class ServerException extends ApiException {
  ServerException([super.message = 'Server error']);
}

class NetworkException extends ApiException {
  NetworkException([super.message = 'Network error']);
}
