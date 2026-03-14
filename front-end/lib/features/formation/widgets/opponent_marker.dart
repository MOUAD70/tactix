import 'package:flutter/material.dart';

class OpponentMarker extends StatelessWidget {
  const OpponentMarker({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shield_outlined, size: 18, color: Colors.white),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }
}