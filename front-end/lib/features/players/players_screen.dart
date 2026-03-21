import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/app_error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import 'providers/player_provider.dart';
import 'player_card.dart';

class PlayersScreen extends ConsumerWidget {
  const PlayersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersState = ref.watch(playerListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Squad management', style: Theme.of(context).textTheme.headlineSmall),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => context.push('/players/add'),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add Player'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: playersState.when(
            data: (players) {
              if (players.isEmpty) {
                return Center(
                  child: Text('No players yet. Tap "Add Player" to get started.', style: Theme.of(context).textTheme.bodyLarge),
                );
              }
              return ListView.separated(
                itemCount: players.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final player = players[index];
                  return PlayerCard(
                    player: player,
                    onTap: () => context.push('/players/${player.id}'),
                  );
                },
              );
            },
            loading: () => const LoadingWidget(message: 'Loading players...'),
            error: (error, stack) => AppErrorWidget(
              message: error.toString(),
              onRetry: () => ref.read(playerListProvider.notifier).loadPlayers(),
            ),
          ),
        ),
      ],
    );
  }
}
