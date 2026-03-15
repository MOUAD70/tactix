import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import '../storage/secure_storage.dart';

/// Centralized HTTP client used by the app.
///
/// All requests go through this class to ensure consistent headers,
/// token injection, response parsing and error mapping.
class ApiClient {
  ApiClient({http.Client? httpClient, SecureStorage? secureStorage})
      : _httpClient = httpClient ?? http.Client(),
        _secureStorage = secureStorage ?? SecureStorage.instance;

  final http.Client _httpClient;
  final SecureStorage _secureStorage;

  Future<Map<String, String>> _buildHeaders({bool authenticated = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authenticated) {
      final token = await _secureStorage.readToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    if (path.startsWith('http')) {
      return Uri.parse(path).replace(
        queryParameters: queryParameters?.map((key, value) => MapEntry(key, value.toString())),
      );
    }

    final baseUri = Uri.parse(ApiConstants.baseUrl);
    return baseUri.replace(
      path: baseUri.path + path,
      queryParameters: queryParameters?.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool authenticated = true,
  }) async {
    http.Response response;
    try {
      response = await _httpClient.get(
        _buildUri(path, queryParameters),
        headers: await _buildHeaders(authenticated: authenticated),
      );
    } catch (_) {
      throw NetworkException();
    }

    return _handleResponse(response);
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    http.Response response;
    try {
      response = await _httpClient.post(
        _buildUri(path),
        headers: await _buildHeaders(authenticated: authenticated),
        body: body == null ? null : jsonEncode(body),
      );
    } catch (_) {
      throw NetworkException();
    }

    return _handleResponse(response);
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    http.Response response;
    try {
      response = await _httpClient.put(
        _buildUri(path),
        headers: await _buildHeaders(authenticated: authenticated),
        body: body == null ? null : jsonEncode(body),
      );
    } catch (_) {
      throw NetworkException();
    }

    return _handleResponse(response);
  }

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    http.Response response;
    try {
      response = await _httpClient.patch(
        _buildUri(path),
        headers: await _buildHeaders(authenticated: authenticated),
        body: body == null ? null : jsonEncode(body),
      );
    } catch (_) {
      throw NetworkException();
    }

    return _handleResponse(response);
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    http.Response response;
    try {
      response = await _httpClient.delete(
        _buildUri(path),
        headers: await _buildHeaders(authenticated: authenticated),
        body: body == null ? null : jsonEncode(body),
      );
    } catch (_) {
      throw NetworkException();
    }

    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      decoded = null;
    }

    switch (response.statusCode) {
      case 200:
      case 201:
      case 204:
        return decoded;
      case 400:
        throw ApiException(_extractMessage(decoded) ?? 'Bad request');
      case 401:
        _secureStorage.deleteToken();
        throw UnauthorizedException(_extractMessage(decoded) ?? 'Unauthorized');
      case 403:
        throw ForbiddenException(_extractMessage(decoded) ?? 'Forbidden');
      case 404:
        throw NotFoundException(_extractMessage(decoded) ?? 'Not found');
      case 422:
        throw ValidationException(
          _extractMessage(decoded) ?? 'Validation failed',
          errors: _extractErrors(decoded),
        );
      case 500:
        throw ServerException(_extractMessage(decoded) ?? 'Server error');
      default:
        throw ApiException(_extractMessage(decoded) ?? 'Unexpected error');
    }
  }

  String? _extractMessage(dynamic decoded) {
    if (decoded is Map<String, dynamic> && decoded['message'] is String) {
      return decoded['message'] as String;
    }
    return null;
  }

  Map<String, dynamic>? _extractErrors(dynamic decoded) {
    if (decoded is Map<String, dynamic> && decoded['errors'] is Map<String, dynamic>) {
      return decoded['errors'] as Map<String, dynamic>;
    }
    return null;
  }
}
