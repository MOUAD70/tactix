import 'package:flutter/material.dart';

import 'package:flutter_application_1/models/player.dart';

class PlayerCard extends StatelessWidget {
  const PlayerCard({
    super.key,
    required this.player,
    required this.onEdit,
    required this.onDelete,
  });

  final Player player;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text('${player.jerseyNumber}')),
        title: Text(player.name),
        subtitle: Text(player.position.label),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
            IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline)),
          ],
        ),
      ),
    );
  }
}