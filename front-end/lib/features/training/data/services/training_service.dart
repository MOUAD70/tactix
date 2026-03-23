import 'package:dio/dio.dart';
import '../models/training_session_model.dart';

class TrainingService {
  final Dio _dio;
  TrainingService(this._dio);

  // تعديل المسارات لتطابق الـ Laravel Terminal عندك
  Future<List<TrainingSessionModel>> getTrainingSessions(int teamId) async {
    final response = await _dio.get('/teams/$teamId/training');
    final List data = response.data['data'] ?? [];
    return data.map((json) => TrainingSessionModel.fromJson(json)).toList();
  }

  Future<TrainingSessionModel> getTrainingSession(int teamId, int sessionId) async {
    final response = await _dio.get('/training/$sessionId');
    return TrainingSessionModel.fromJson(response.data['data']);
  }

  Future<TrainingSessionModel> createTrainingSession(int teamId, Map<String, dynamic> data) async {
    final response = await _dio.post('/teams/$teamId/training', data: data);
    return TrainingSessionModel.fromJson(response.data['data']);
  }

  Future<void> saveTacticalData(int teamId, int sessionId, Map<String, dynamic> data) async {
    await _dio.put('/training/$sessionId', data: data);
  }

  Future<void> deleteSession(int teamId, int sessionId) async {
    await _dio.delete('/training/$sessionId');
  }
}