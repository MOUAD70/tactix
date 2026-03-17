import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/models/formation_model.dart';
import '../data/models/formation_position_model.dart';
import '../data/repositories/formation_repository.dart';

final formationRepositoryProvider = Provider<FormationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FormationRepository(apiClient: apiClient);
});

final formationNotifierProvider = StateNotifierProvider<FormationNotifier, FormationState>(
  (ref) => FormationNotifier(ref.watch(formationRepositoryProvider)),
);

class FormationState {
  const FormationState({
    required this.list,
    required this.active,
    required this.updatingPositionIds,
  });

  final AsyncValue<List<FormationModel>> list;
  final AsyncValue<FormationModel?> active;
  final Set<int> updatingPositionIds;

  FormationState copyWith({
    AsyncValue<List<FormationModel>>? list,
    AsyncValue<FormationModel?>? active,
    Set<int>? updatingPositionIds,
  }) {
    return FormationState(
      list: list ?? this.list,
      active: active ?? this.active,
      updatingPositionIds: updatingPositionIds ?? this.updatingPositionIds,
    );
  }

  factory FormationState.initial() {
    return FormationState(
      list: const AsyncValue.loading(),
      active: const AsyncValue.loading(),
      updatingPositionIds: <int>{},
    );
  }
}

class FormationNotifier extends StateNotifier<FormationState> {
  FormationNotifier(this._repository) : super(FormationState.initial());

  final FormationRepository _repository;

  Future<void> loadFormations() async {
    state = state.copyWith(list: const AsyncValue.loading());
    try {
      final list = await _repository.fetchFormations();
      state = state.copyWith(list: AsyncValue.data(list));
      if (list.isNotEmpty) {
        selectFormation(list.first.id);
      } else {
        state = state.copyWith(active: const AsyncValue.data(null));
      }
    } catch (error, stack) {
      state = state.copyWith(list: AsyncValue.error(error, stack));
    }
  }

  Future<void> createFormation(String name, List<FormationPositionModel> positions) async {
    state = state.copyWith(list: const AsyncValue.loading());
    try {
      final newFormation = await _repository.createFormation(
        name: name,
        positions: positions,
      );
      
      // Reload the list to include the new formation
      final list = await _repository.fetchFormations();
      state = state.copyWith(
        list: AsyncValue.data(list),
        active: AsyncValue.data(newFormation),
      );
    } catch (error) {
      // Restore previous state by reloading
      loadFormations();
      rethrow;
    }
  }

  Future<void> selectFormation(int formationId) async {
    state = state.copyWith(active: const AsyncValue.loading());
    try {
      final formation = await _repository.fetchFormation(formationId);
      state = state.copyWith(active: AsyncValue.data(formation));
    } catch (error, stack) {
      state = state.copyWith(active: AsyncValue.error(error, stack));
    }
  }

  Future<void> updatePosition({
    required int formationId,
    required int positionId,
    required double x,
    required double y,
  }) async {
    final active = state.active;
    if (active.value == null) return;

    final current = active.value!;
    final oldPosition = current.positions.firstWhere((p) => p.id == positionId, orElse: () => FormationPositionModel(id: positionId, role: '', x: 0, y: 0));

    state = state.copyWith(
      active: AsyncValue.data(
        current.copyWith(
          positions: current.positions
              .map((p) => p.id == positionId ? p.copyWith(x: x, y: y) : p)
              .toList(growable: false),
        ),
      ),
      updatingPositionIds: {...state.updatingPositionIds, positionId},
    );

    try {
      await _repository.updatePosition(
        formationId: formationId,
        positionId: positionId,
        x: x,
        y: y,
      );
    } catch (_) {
      // Revert to old position
      state = state.copyWith(
        active: AsyncValue.data(
          current.copyWith(
            positions: current.positions
                .map((p) => p.id == positionId ? oldPosition : p)
                .toList(growable: false),
          ),
        ),
      );
      rethrow;
    } finally {
      final updatedIds = Set<int>.from(state.updatingPositionIds);
      updatedIds.remove(positionId);
      state = state.copyWith(updatingPositionIds: updatedIds);
    }
  }
}
