import 'package:flutter/material.dart';

class PlayerMarker extends StatelessWidget {
  const PlayerMarker({
    super.key,
    required this.label,
    required this.playerName,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String playerName;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Theme.of(context).colorScheme.primary : const Color(0xFF0EA5E9);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person, size: 18, color: Colors.white),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
            Text(
              playerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}