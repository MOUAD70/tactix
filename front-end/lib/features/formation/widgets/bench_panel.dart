import 'package:flutter/material.dart';

import 'package:flutter_application_1/models/player.dart';

class BenchPanel extends StatelessWidget {
  const BenchPanel({
    super.key,
    required this.benchPlayers,
    required this.selectedPlayerId,
    required this.onSelectPlayer,
  });

  final List<Player> benchPlayers;
  final int? selectedPlayerId;
  final ValueChanged<int> onSelectPlayer;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bench players', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text('Tap a player then tap a pitch marker, or drag onto the field. Long-press starters on the pitch to swap them.'),
            const SizedBox(height: 12),
            if (benchPlayers.isEmpty)
              const Text('All players are currently assigned to the pitch.')
            else
              for (final player in benchPlayers)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Draggable<int>(
                    data: player.id,
                    feedback: Material(
                      color: Colors.transparent,
                      child: _BenchPlayerTile(player: player, isSelected: true),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.35,
                      child: _BenchPlayerTile(
                        player: player,
                        isSelected: selectedPlayerId == player.id,
                        onTap: () => onSelectPlayer(player.id),
                      ),
                    ),
                    child: _BenchPlayerTile(
                      player: player,
                      isSelected: selectedPlayerId == player.id,
                      onTap: () => onSelectPlayer(player.id),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _BenchPlayerTile extends StatelessWidget {
  const _BenchPlayerTile({
    required this.player,
    required this.isSelected,
    this.onTap,
  });

  final Player player;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary.withValues(alpha: 0.18) : const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? colorScheme.primary : Colors.white10,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(child: Text('${player.jerseyNumber}')),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(player.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(player.position.label, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle : Icons.open_with,
                  color: isSelected ? colorScheme.primary : Colors.white70,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}