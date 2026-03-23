import '../models/training_session_model.dart';
import '../services/training_service.dart';

class TrainingRepository {
  final TrainingService apiClient;
  TrainingRepository({required this.apiClient});

  Future<List<TrainingSessionModel>> fetchSessions({required int teamId}) async {
    return await apiClient.getTrainingSessions(teamId);
  }

  Future<TrainingSessionModel> fetchSession(int sessionId, {required int teamId}) async {
    return await apiClient.getTrainingSession(teamId, sessionId);
  }

  Future<TrainingSessionModel> createSession({required int teamId, required String title, required String description, required DateTime sessionDate}) async {
    return await apiClient.createTrainingSession(teamId, {
      'title': title,
      'description': description,
      'session_date': sessionDate.toIso8601String(),
    });
  }

  Future<void> saveTacticalData({required int sessionId, required int teamId, required Map<String, dynamic> data}) async {
    await apiClient.saveTacticalData(teamId, sessionId, data);
  }
}