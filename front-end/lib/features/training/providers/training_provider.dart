import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../core/errors/failures.dart';
import '../data/models/training_attendance_model.dart';
import '../data/models/training_session_model.dart';
import '../data/repositories/training_repository.dart';

final trainingRepositoryProvider = Provider<TrainingRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TrainingRepository(apiClient: apiClient);
});

final trainingListProvider = StateNotifierProvider<TrainingListNotifier, AsyncValue<List<TrainingSessionModel>>>(
  (ref) {
    final authState = ref.watch(authProvider);
    final teamId = authState.asData?.value?.teamId;
    return TrainingListNotifier(ref.watch(trainingRepositoryProvider), teamId: teamId);
  },
);

final trainingSessionProvider = StateNotifierProvider.family<TrainingSessionNotifier, AsyncValue<TrainingSessionModel?>, int>(
  (ref, sessionId) {
    final repository = ref.watch(trainingRepositoryProvider);
    final authState = ref.watch(authProvider);
    final teamId = authState.asData?.value?.teamId;
    return TrainingSessionNotifier(repository, sessionId: sessionId, teamId: teamId);
  },
);

class TrainingListNotifier extends StateNotifier<AsyncValue<List<TrainingSessionModel>>> {
  TrainingListNotifier(this._repository, {required this.teamId}) : super(const AsyncValue.loading()) {
    loadSessions();
  }

  final TrainingRepository _repository;
  final int? teamId;

  Future<void> loadSessions() async {
    if (teamId == null) {
      state = AsyncValue.error(AuthenticationFailure('Team not found'), StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final sessions = await _repository.fetchSessions(teamId: teamId!);
      state = AsyncValue.data(sessions);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> createSession({
    required String title,
    required String description,
    required DateTime sessionDate,
  }) async {
    if (teamId == null) return;

    state = const AsyncValue.loading();
    try {
      final created = await _repository.createSession(
        teamId: teamId!,
        title: title,
        description: description,
        sessionDate: sessionDate,
      );
      final list = state.asData?.value ?? [];
      state = AsyncValue.data([created, ...list]);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> deleteSession(int sessionId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteSession(sessionId);
      final list = state.asData?.value ?? [];
      state = AsyncValue.data(list.where((s) => s.id != sessionId).toList(growable: false));
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
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
    if (teamId == null) {
      state = AsyncValue.error(AuthenticationFailure('Team not found'), StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final session = await _repository.fetchSession(sessionId);
      state = AsyncValue.data(session);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> submitAttendance(List<TrainingAttendanceModel> attendance) async {
    final current = state.asData?.value;
    if (current == null) return;

    state = const AsyncValue.loading();
    try {
      final summary = await _repository.submitAttendance(sessionId: sessionId, attendance: attendance);
      final updated = current.copyWith(summary: summary, attendance: attendance);
      state = AsyncValue.data(updated);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> updateAttendance(TrainingAttendanceModel attendance) async {
    final current = state.asData?.value;
    if (current == null) return;

    state = const AsyncValue.loading();
    try {
      final updatedRecord = await _repository.updateAttendance(
        sessionId: sessionId,
        playerId: attendance.playerId,
        attendance: attendance,
      );

      final updatedList = current.attendance
              ?.map((item) => item.playerId == updatedRecord.playerId ? updatedRecord : item)
              .toList(growable: false) ??
          <TrainingAttendanceModel>[];

      state = AsyncValue.data(current.copyWith(attendance: updatedList));
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}
