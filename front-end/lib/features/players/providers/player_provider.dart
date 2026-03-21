import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../core/errors/failures.dart';
import '../data/models/player_model.dart';
import '../data/repositories/player_repository.dart';

final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PlayerRepository(apiClient: apiClient);
});

final playerListProvider = StateNotifierProvider<PlayerNotifier, AsyncValue<List<PlayerModel>>>(
  (ref) {
    final authState = ref.watch(authProvider);
    final user = authState.asData?.value;
    return PlayerNotifier(
      repository: ref.watch(playerRepositoryProvider),
      teamId: user?.teamId,
    );
  },
);

class PlayerNotifier extends StateNotifier<AsyncValue<List<PlayerModel>>> {
  PlayerNotifier({required this.repository, required this.teamId}) : super(const AsyncValue.loading()) {
    if (teamId != null) {
      loadPlayers();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  final PlayerRepository repository;
  final int? teamId;

  Future<void> loadPlayers() async {
    if (teamId == null) {
      state = AsyncValue.error(
        AuthenticationFailure('No team found. Please log in again.'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      final players = await repository.fetchPlayers(teamId: teamId!);
      state = AsyncValue.data(players);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> addPlayer(PlayerModel player) async {
    if (teamId == null) return;

    try {
      final created = await repository.createPlayer(teamId: teamId!, player: player);
      final list = state.asData?.value ?? [];
      state = AsyncValue.data([created, ...list]);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> updatePlayer(PlayerModel player) async {
    try {
      final updated = await repository.updatePlayer(player);
      final list = state.asData?.value ?? [];
      state = AsyncValue.data(
        list.map((p) => p.id == updated.id ? updated : p).toList(growable: false),
      );
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> deletePlayer(int playerId) async {
    try {
      await repository.deletePlayer(playerId);
      final list = state.asData?.value ?? [];
      state = AsyncValue.data(
        list.where((p) => p.id != playerId).toList(growable: false),
      );
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}
