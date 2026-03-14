import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/state/app_state.dart';
import 'package:flutter_application_1/features/players/add_player_screen.dart';
import 'package:flutter_application_1/features/players/edit_player_screen.dart';
import 'package:flutter_application_1/features/players/player_card.dart';
import 'package:flutter_application_1/models/player.dart';

class PlayersScreen extends StatelessWidget {
  const PlayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Squad management', style: Theme.of(context).textTheme.headlineSmall),
            const Spacer(),
            FilledButton.icon(
              onPressed: () async {
                final player = await Navigator.of(context).push<Player>(
                  MaterialPageRoute(builder: (_) => const AddPlayerScreen()),
                );
                if (player != null) state.addPlayer(player);
              },
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add Player'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: state.players.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final player = state.players[index];
              return PlayerCard(
                player: player,
                onEdit: () async {
                  final updated = await Navigator.of(context).push<Player>(
                    MaterialPageRoute(builder: (_) => EditPlayerScreen(player: player)),
                  );
                  if (updated != null) state.updatePlayer(updated);
                },
                onDelete: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete player'),
                      content: Text('Remove ${player.name} from the squad?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                      ],
                    ),
                  );
                  if (confirmed ?? false) state.deletePlayer(player.id);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}