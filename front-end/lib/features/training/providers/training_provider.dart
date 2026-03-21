import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/models/training_session_model.dart';
import '../data/models/training_attendance_model.dart';
import '../data/repositories/training_repository.dart';
import '../data/services/training_service.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://127.0.0.1:8000/api',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      final authState = ref.read(authProvider);
      final token = authState.value?.token;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
  ));
  return dio;
});

final trainingServiceProvider = Provider<TrainingService>((ref) => TrainingService(ref.watch(dioProvider)));
final trainingRepositoryProvider = Provider<TrainingRepository>((ref) => TrainingRepository(apiClient: ref.watch(trainingServiceProvider)));

final trainingListProvider = StateNotifierProvider<TrainingListNotifier, AsyncValue<List<TrainingSessionModel>>>((ref) {
  final teamId = ref.watch(authProvider).value?.teamId;
  return TrainingListNotifier(ref.watch(trainingRepositoryProvider), teamId: teamId);
});

final trainingSessionProvider = StateNotifierProvider.family<TrainingSessionNotifier, AsyncValue<TrainingSessionModel?>, int>((ref, sessionId) {
  final teamId = ref.watch(authProvider).value?.teamId;
  return TrainingSessionNotifier(ref.watch(trainingRepositoryProvider), sessionId: sessionId, teamId: teamId);
});

class TrainingListNotifier extends StateNotifier<AsyncValue<List<TrainingSessionModel>>> {
  TrainingListNotifier(this._repository, {required this.teamId}) : super(const AsyncValue.loading()) {
    loadSessions();
  }
  final TrainingRepository _repository;
  final int? teamId;

  Future<void> loadSessions() async {
    if (teamId == null) return;
    state = const AsyncValue.loading();
    try {
      final sessions = await _repository.fetchSessions(teamId: teamId!);
      state = AsyncValue.data(sessions);
    } catch (e, st) { state = AsyncValue.error(e, st); }
  }

  Future<void> createSession({required String title, required String description, required DateTime date}) async {
    if (teamId == null) return;
    try {
      final created = await _repository.createSession(
        teamId: teamId!, 
        title: title, 
        description: description, 
        sessionDate: date
      );
      state.whenData((list) => state = AsyncValue.data([created, ...list]));
    } catch (e, st) { 
      print("Create Session Error: $e");
      rethrow; 
    }
  }
}

class TrainingSessionNotifier extends StateNotifier<AsyncValue<TrainingSessionModel?>> {
  TrainingSessionNotifier(this._repository, {required this.sessionId, required this.teamId}) : super(const AsyncValue.loading()) {
    loadSession();
  }
  final TrainingRepository _repository;
  final int sessionId;
  final int? teamId;

  Future<void> loadSession() async {
    if (teamId == null) return;
    state = const AsyncValue.loading();
    try {
      final session = await _repository.fetchSession(sessionId, teamId: teamId!);
      state = AsyncValue.data(session);
    } catch (e, st) { state = AsyncValue.error(e, st); }
  }

  Future<void> submitAttendance(List<TrainingAttendanceModel> attendanceList) async {
    if (teamId == null) return;
    try {
      final data = {'attendance': attendanceList.map((a) => a.toJson()).toList()};
      await _repository.saveTacticalData(sessionId: sessionId, teamId: teamId!, data: data);
      await loadSession();
    } catch (e, st) { state = AsyncValue.error(e, st); }
  }
}