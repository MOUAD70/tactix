import 'package:flutter_application_1/core/api/api_client.dart';
import 'package:flutter_application_1/core/constants/api_constants.dart';

import '../models/player_model.dart';

class PlayerRepository {
  PlayerRepository({required this.apiClient});

  final ApiClient apiClient;

  /// GET /teams/{team_id}/players
  /// Backend response: { data: [ ...players ] }
  Future<List<PlayerModel>> fetchPlayers({required int teamId}) async {
    final response = await apiClient.get(
      ApiConstants.players.replaceAll('{team_id}', teamId.toString()),
    ) as Map<String, dynamic>;

    final data = response['data'] as List;
    return data
        .cast<Map<String, dynamic>>()
        .map(PlayerModel.fromJson)
        .toList(growable: false);
  }

  /// GET /players/{id}
  /// Backend response: { data: { ...player } }
  Future<PlayerModel> fetchPlayer(int playerId) async {
    final response = await apiClient.get(
      ApiConstants.player.replaceAll('{id}', playerId.toString()),
    ) as Map<String, dynamic>;

    return PlayerModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// POST /teams/{team_id}/players
  /// Backend response: { message, data: { ...player } }
  Future<PlayerModel> createPlayer({required int teamId, required PlayerModel player}) async {
    final response = await apiClient.post(
      ApiConstants.players.replaceAll('{team_id}', teamId.toString()),
      body: {
        'name': player.name,
        'jersey_number': player.jerseyNumber,
        'position': player.position.name,
      },
    ) as Map<String, dynamic>;

    return PlayerModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// PUT /players/{id}
  /// Backend response: { message, data: { ...player } }
  Future<PlayerModel> updatePlayer(PlayerModel player) async {
    final response = await apiClient.put(
      ApiConstants.player.replaceAll('{id}', player.id.toString()),
      body: {
        'name': player.name,
        'jersey_number': player.jerseyNumber,
        'position': player.position.name,
      },
    ) as Map<String, dynamic>;

    return PlayerModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// DELETE /players/{id}
  /// Backend response: { message }
  Future<void> deletePlayer(int playerId) async {
    await apiClient.delete(ApiConstants.player.replaceAll('{id}', playerId.toString()));
  }
}
