import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'data/models/player_model.dart';
import 'providers/player_provider.dart';

class PlayerDetailScreen extends ConsumerWidget {
  const PlayerDetailScreen({super.key, required this.playerId});

  final int? playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersState = ref.watch(playerListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Player details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              final players = playersState.asData?.value ?? <PlayerModel>[];
              // Fix: use where() before firstWhere to avoid null cast on non-nullable
              final matching = players.where((p) => p.id == playerId);
              if (matching.isEmpty) return;
              context.push('/players/${matching.first.id}/edit');
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Delete player'),
                        content: const Text('Are you sure you want to delete this player?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  ) ??
                  false;

              if (!confirmed || playerId == null) return;

              try {
                await ref.read(playerListProvider.notifier).deletePlayer(playerId!);
                if (context.mounted) context.pop();
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error.toString())),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: playersState.when(
        data: (players) {
          // Fix: use where() to safely find the player — avoids firstWhere() null cast.
          final matching = players.where((p) => p.id == playerId);
          if (matching.isEmpty) {
            return const Center(child: Text('Player not found'));
          }
          final player = matching.first;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player.name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('Jersey: #${player.jerseyNumber}'),
                const SizedBox(height: 4),
                Text('Position: ${player.position.label}'),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => context.push('/players/${player.id}/edit'),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Player'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
      ),
    );
  }
}
