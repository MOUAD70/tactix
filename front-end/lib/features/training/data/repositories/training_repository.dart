import 'package:flutter_application_1/core/api/api_client.dart';
import 'package:flutter_application_1/core/constants/api_constants.dart';

import '../models/training_attendance_model.dart';
import '../models/training_session_model.dart';

class TrainingRepository {
  TrainingRepository({required this.apiClient});

  final ApiClient apiClient;

  /// GET /teams/{team_id}/training
  /// Backend response: { data: [ ...sessions ] }
  Future<List<TrainingSessionModel>> fetchSessions({required int teamId}) async {
    final response = await apiClient.get(
      ApiConstants.trainingSessions.replaceAll('{team_id}', teamId.toString()),
    ) as Map<String, dynamic>;

    final data = response['data'] as List;
    return data
        .cast<Map<String, dynamic>>()
        .map(TrainingSessionModel.fromJson)
        .toList(growable: false);
  }

  /// GET /training/{id}
  /// Backend response: { data: { ...session with attendance } }
  Future<TrainingSessionModel> fetchSession(int sessionId) async {
    final response = await apiClient.get(
      ApiConstants.trainingSession.replaceAll('{id}', sessionId.toString()),
    ) as Map<String, dynamic>;

    return TrainingSessionModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// POST /teams/{team_id}/training
  /// Backend response: { message, data: { ...session } }
  Future<TrainingSessionModel> createSession({
    required int teamId,
    required String title,
    required String description,
    required DateTime sessionDate,
  }) async {
    final response = await apiClient.post(
      ApiConstants.trainingSessions.replaceAll('{team_id}', teamId.toString()),
      body: {
        'title': title,
        'description': description,
        'session_date': sessionDate.toIso8601String().split('T').first, // date only
      },
    ) as Map<String, dynamic>;

    return TrainingSessionModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// PUT /training/{id}
  /// Backend response: { message, data: { ...session } }
  Future<TrainingSessionModel> updateSession({
    required int sessionId,
    required String title,
    required String description,
    required DateTime sessionDate,
  }) async {
    final response = await apiClient.put(
      ApiConstants.trainingSession.replaceAll('{id}', sessionId.toString()),
      body: {
        'title': title,
        'description': description,
        'session_date': sessionDate.toIso8601String().split('T').first,
      },
    ) as Map<String, dynamic>;

    return TrainingSessionModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// DELETE /training/{id}
  /// Backend response: { message }
  Future<void> deleteSession(int sessionId) async {
    await apiClient.delete(
      ApiConstants.trainingSession.replaceAll('{id}', sessionId.toString()),
    );
  }

  /// POST /training/{id}/attendance  (bulk — replaces all records)
  /// Payload: { attendance: [ { player_id, status, note? } ] }
  /// Backend response: { message, data: { ...session with summary } }
  Future<TrainingSummary> submitAttendance({
    required int sessionId,
    required List<TrainingAttendanceModel> attendance,
  }) async {
    final response = await apiClient.post(
      ApiConstants.trainingAttendance.replaceAll('{id}', sessionId.toString()),
      body: {
        'attendance': attendance.map((entry) => entry.toJson()).toList(growable: false),
      },
    ) as Map<String, dynamic>;

    // Backend returns { message, data: { ...session, summary: { total, present, absent, late } } }
    final data = response['data'] as Map<String, dynamic>;
    return TrainingSummary.fromJson(data['summary'] as Map<String, dynamic>);
  }

  /// PATCH /training/{id}/attendance/{player_id}  (single update)
  /// Backend response: { message, data: { ...attendance_record } }
  Future<TrainingAttendanceModel> updateAttendance({
    required int sessionId,
    required int playerId,
    required TrainingAttendanceModel attendance,
  }) async {
    final response = await apiClient.patch(
      ApiConstants.trainingAttendanceItem
          .replaceAll('{id}', sessionId.toString())
          .replaceAll('{player_id}', playerId.toString()),
      body: attendance.toJson(),
    ) as Map<String, dynamic>;

    return TrainingAttendanceModel.fromJson(response['data'] as Map<String, dynamic>);
  }
}
