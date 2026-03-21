import 'package:flutter/material.dart';

import 'data/models/player_model.dart';

class PlayerCard extends StatelessWidget {
  const PlayerCard({
    super.key,
    required this.player,
    this.onTap,
  });

  final PlayerModel player;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(child: Text('${player.jerseyNumber}')),
        title: Text(player.name),
        subtitle: Text(player.position.label),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
