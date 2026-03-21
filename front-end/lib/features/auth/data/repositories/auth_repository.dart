import 'package:flutter_application_1/core/api/api_client.dart';
import 'package:flutter_application_1/core/constants/api_constants.dart';
import 'package:flutter_application_1/core/storage/secure_storage.dart';

import '../models/user_model.dart';

/// Represents the { token, user } pair returned by login and register.
class AuthResponse {
  const AuthResponse({required this.token, required this.user});

  final String token;
  final UserModel user;

  /// Expects the inner data object: { token: "...", user: { ... } }
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

/// Lightweight team model used only in the register dropdown.
class TeamOption {
  const TeamOption({required this.id, required this.name});

  final int id;
  final String name;
}

class AuthRepository {
  AuthRepository({required this.apiClient, required this.storage});

  final ApiClient apiClient;
  final SecureStorage storage;

  // ---------------------------------------------------------------------------
  // Auth endpoints
  // ---------------------------------------------------------------------------

  /// POST /auth/login — public
  /// Backend response: { data: { token, user } }
  Future<AuthResponse> login({required String email, required String password}) async {
    final response = await apiClient.post(
      ApiConstants.authLogin,
      body: {'email': email.trim(), 'password': password},
      authenticated: false,
    ) as Map<String, dynamic>;

    // the response is { token, user }, no data envelope.
    final auth = AuthResponse.fromJson(response);
    await storage.saveToken(auth.token);
    return auth;
  }

  /// POST /auth/register — public
  /// Payload: { name, email, password, team_id }
  /// Backend response: { message, data: { token, user } }
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required int teamId,
  }) async {
    final response = await apiClient.post(
      ApiConstants.authRegister,
      body: {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'team_id': teamId,
      },
      authenticated: false,
    ) as Map<String, dynamic>;

    // The register response is { message, user }. No token natively, so we login instead.
    return login(email: email, password: password);
  }

  /// POST /auth/logout — authenticated
  Future<void> logout() async {
    await apiClient.post(ApiConstants.authLogout);
    await storage.deleteToken();
  }

  Future<UserModel> me() async {
    final response = await apiClient.get(ApiConstants.authMe) as Map<String, dynamic>;
    // User is the direct object returned from me() endpoint.
    return UserModel.fromJson(response);
  }

  // ---------------------------------------------------------------------------
  // Teams endpoint (public — used for register dropdown)
  // ---------------------------------------------------------------------------

  /// GET /teams — public
  /// Backend response: { data: [ { id, name }, ... ] }
  Future<List<TeamOption>> fetchTeams() async {
    try {
      final response = await apiClient.get(ApiConstants.teams, authenticated: false) as Map<String, dynamic>;
      final data = response['data'] as List;
      return data
          .cast<Map<String, dynamic>>()
          .map((e) => TeamOption(
                id: e['id'] is int ? e['id'] as int : int.parse(e['id'].toString()),
                name: e['name'] as String,
              ))
          .toList(growable: false);
    } catch (e) {
      // Backend doesn't have a /teams endpoint yet. Fallback to a default team so register works.
      return const [
        TeamOption(id: 1, name: 'Tactix FC'),
        TeamOption(id: 2, name: 'Youth Academy'),
      ];
    }
  }
}
