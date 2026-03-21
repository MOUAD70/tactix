import 'package:flutter_application_1/core/api/api_client.dart';
import 'package:flutter_application_1/core/constants/api_constants.dart';

import '../models/formation_model.dart';
import '../models/formation_position_model.dart';

class FormationRepository {
  FormationRepository({required this.apiClient});

  final ApiClient apiClient;

  /// GET /formations
  /// Backend response: { data: [ ...formations ] }
  Future<List<FormationModel>> fetchFormations() async {
    final response = await apiClient.get(ApiConstants.formations) as Map<String, dynamic>;
    final data = response['data'] as List;
    return data
        .cast<Map<String, dynamic>>()
        .map(FormationModel.fromJson)
        .toList(growable: false);
  }

  /// GET /formations/{id}
  /// Backend response: { data: { ...formation } }
  Future<FormationModel> fetchFormation(int id) async {
    final response = await apiClient.get(
      ApiConstants.formation.replaceAll('{id}', id.toString()),
    ) as Map<String, dynamic>;

    return FormationModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// POST /formations
  /// Backend response: { message, data: { ...formation } }
  Future<FormationModel> createFormation({
    required String name,
    required List<FormationPositionModel> positions,
  }) async {
    final response = await apiClient.post(
      ApiConstants.formations,
      body: {
        'name': name,
        'positions': positions.map((p) => p.toJson()).toList(growable: false),
      },
    ) as Map<String, dynamic>;

    return FormationModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// PUT /formations/{id}
  /// Backend response: { message, data: { ...formation } }
  Future<FormationModel> updateFormation({
    required int id,
    String? name,
    List<FormationPositionModel>? positions,
  }) async {
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (positions != null)
        'positions': positions.map((p) => p.toJson()).toList(growable: false),
    };

    final response = await apiClient.put(
      ApiConstants.formation.replaceAll('{id}', id.toString()),
      body: body.isEmpty ? null : body,
    ) as Map<String, dynamic>;

    return FormationModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// DELETE /formations/{id}
  /// Backend response: { message }
  Future<void> deleteFormation(int id) async {
    await apiClient.delete(ApiConstants.formation.replaceAll('{id}', id.toString()));
  }

  /// POST /formations/{id}/copy
  /// Backend response: { message, data: { ...formation } }
  Future<FormationModel> copyFormation(int id) async {
    final response = await apiClient.post(
      ApiConstants.formationCopy.replaceAll('{id}', id.toString()),
    ) as Map<String, dynamic>;

    return FormationModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// PATCH /formations/{formation_id}/positions/{position_id}
  /// Backend response: { message, data: { ...position } }
  Future<FormationPositionModel> updatePosition({
    required int formationId,
    required int positionId,
    required double x,
    required double y,
  }) async {
    final response = await apiClient.patch(
      ApiConstants.formationPosition
          .replaceAll('{formation_id}', formationId.toString())
          .replaceAll('{position_id}', positionId.toString()),
      body: {'x': x.round(), 'y': y.round()},
    ) as Map<String, dynamic>;

    return FormationPositionModel.fromJson(response['data'] as Map<String, dynamic>);
  }
}
