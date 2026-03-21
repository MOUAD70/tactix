import 'package:flutter/material.dart';

import 'package:flutter_application_1/models/player_position.dart';

class InstructionPanel extends StatefulWidget {
  const InstructionPanel({
    super.key,
    required this.position,
    required this.playerName,
    required this.onChanged,
    required this.onClearAssignment,
  });

  final PlayerPosition? position;
  final String? playerName;
  final ValueChanged<String> onChanged;
  final VoidCallback onClearAssignment;

  @override
  State<InstructionPanel> createState() => _InstructionPanelState();
}

class _InstructionPanelState extends State<InstructionPanel> {
  static const List<String> _presets = <String>[
    'Stay Back',
    'Overlap',
    'Press High',
    'Mark Opponent',
    'Cover Center',
  ];

  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.position?.instructions ?? '');
  }

  @override
  void didUpdateWidget(covariant InstructionPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.position?.id != widget.position?.id) {
      _controller.text = widget.position?.instructions ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _applyPreset(String instruction) {
    final lines = _controller.text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: true);

    if (!lines.contains(instruction)) {
      lines.add(instruction);
    }

    final updated = lines.join('\n');
    _controller
      ..text = updated
      ..selection = TextSelection.collapsed(offset: updated.length);
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: widget.position == null
            ? const Text('Tap a player marker to view instructions, then drag it on the pitch to refine its tactical location.')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Instruction panel', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('Position: ${widget.position!.label}')),
                      Chip(label: Text('x: ${widget.position!.x.toStringAsFixed(2)}')),
                      Chip(label: Text('y: ${widget.position!.y.toStringAsFixed(2)}')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Player: ${widget.playerName ?? 'Unassigned'}'),
                  const SizedBox(height: 12),
                  Text('Quick instructions', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final preset in _presets)
                        ActionChip(label: Text(preset), onPressed: () => _applyPreset(preset)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Tactical instructions',
                      hintText: 'Stay Back, Press High, Mark Opponent... ',
                    ),
                    onChanged: widget.onChanged,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: widget.playerName == null ? null : widget.onClearAssignment,
                      icon: const Icon(Icons.person_remove_outlined),
                      label: const Text('Send player to bench'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}