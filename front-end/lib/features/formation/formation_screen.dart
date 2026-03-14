import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/state/app_state.dart';
import 'package:flutter_application_1/features/formation/widgets/bench_panel.dart';
import 'package:flutter_application_1/features/formation/widgets/football_field.dart';
import 'package:flutter_application_1/features/formation/widgets/instruction_panel.dart';

class FormationBoard extends StatelessWidget {
  const FormationBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formation')),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: FormationScreen(),
        ),
      ),
    );
  }
}

class FormationScreen extends StatefulWidget {
  const FormationScreen({super.key});

  @override
  State<FormationScreen> createState() => _FormationScreenState();
}

class _FormationScreenState extends State<FormationScreen> {
  String? _selectedPositionId;
  String? _selectedBenchPlayerId;

  Future<void> _showSaveFormationDialog(TactixAppState state) async {
    final controller = TextEditingController(text: '${state.formation.name} Copy');

    final savedName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save current setup'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Setup name',
              hintText: 'e.g. High Press Variant',
            ),
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (savedName == null || savedName.trim().isEmpty) return;

    state.saveCurrentFormationAs(savedName);
    setState(() {
      _selectedBenchPlayerId = null;
      _selectedPositionId = null;
    });
  }

  void _handlePositionSelection(TactixAppState state, String positionId) {
    final selectedBenchPlayerId = _selectedBenchPlayerId;
    if (selectedBenchPlayerId != null) {
      state.assignPlayerToPosition(playerId: selectedBenchPlayerId, positionId: positionId);
    }

    setState(() {
      _selectedPositionId = positionId;
      _selectedBenchPlayerId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final selected = _selectedPositionId == null ? null : state.formation.findPosition(_selectedPositionId!);
    final selectedPlayerName = state.playerById(selected?.playerId)?.name;
    final selectedBenchPlayer = state.playerById(_selectedBenchPlayerId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 12,
              spacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Interactive tactical board', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    const Text(
                      'Switch between saved tactical setups, long-press starters to swap slots, and save polished variants for different match plans.',
                    ),
                  ],
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Chip(label: Text('Shape ${state.formation.schemeId}')),
                    Chip(label: Text('${state.savedFormations.length} saved setups')),
                    if (selectedBenchPlayer != null)
                      InputChip(
                        label: Text('Selected: ${selectedBenchPlayer.name}'),
                        onDeleted: () => setState(() => _selectedBenchPlayerId = null),
                      ),
                    OutlinedButton.icon(
                      onPressed: () => _showSaveFormationDialog(state),
                      icon: const Icon(Icons.bookmark_add_outlined),
                      label: const Text('Save Setup'),
                    ),
                    OutlinedButton.icon(
                      onPressed: state.resetFormationLayout,
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Reset Active Layout'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: state.addOpponentPlayer,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Add Opponent'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1100;
              final formationsPanel = Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Saved formations', style: Theme.of(context).textTheme.titleMedium),
                          const Spacer(),
                          Text('Tap to switch', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final savedFormation in state.savedFormations)
                            InputChip(
                              selected: savedFormation.id == state.activeFormationId,
                              label: Text(savedFormation.name),
                              avatar: Icon(
                                savedFormation.isPreset ? Icons.sports_soccer : Icons.bookmark,
                                size: 18,
                              ),
                              onSelected: (_) {
                                state.activateFormation(savedFormation.id);
                                setState(() {
                                  _selectedBenchPlayerId = null;
                                  _selectedPositionId = null;
                                });
                              },
                              onDeleted: savedFormation.isPreset
                                  ? null
                                  : () {
                                      state.deleteSavedFormation(savedFormation.id);
                                      setState(() {
                                        _selectedBenchPlayerId = null;
                                        _selectedPositionId = null;
                                      });
                                    },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );

              final field = FootballField(
                positions: state.formation.positions,
                opponents: state.opponentPlayers,
                selectedPositionId: _selectedPositionId,
                onSelectPosition: (id) => _handlePositionSelection(state, id),
                resolvePlayerName: (position) => state.playerById(position.playerId)?.name ?? 'Unassigned',
                onMovePosition: (positionId, x, y) => state.movePosition(positionId, x: x, y: y),
                onSnapPosition: state.snapPosition,
                onAssignPlayerToPosition: (playerId, positionId) {
                  state.assignPlayerToPosition(playerId: playerId, positionId: positionId);
                  setState(() {
                    _selectedBenchPlayerId = null;
                    _selectedPositionId = positionId;
                  });
                },
                onSwapPlayersBetweenPositions: (fromPositionId, toPositionId) {
                  state.swapPositionAssignments(
                    fromPositionId: fromPositionId,
                    toPositionId: toPositionId,
                  );
                  setState(() => _selectedPositionId = toPositionId);
                },
                onMoveOpponent: (opponentId, x, y) => state.moveOpponentPlayer(opponentId, x: x, y: y),
              );

              final sidePanel = SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    formationsPanel,
                    const SizedBox(height: 16),
                    BenchPanel(
                      benchPlayers: state.benchPlayers,
                      selectedPlayerId: _selectedBenchPlayerId,
                      onSelectPlayer: (playerId) {
                        setState(() {
                          _selectedBenchPlayerId = _selectedBenchPlayerId == playerId ? null : playerId;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Opponent players', style: Theme.of(context).textTheme.titleMedium),
                                const Spacer(),
                                Text('${state.opponentPlayers.length} markers'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            for (final opponent in state.opponentPlayers)
                              ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFFDC2626),
                                  child: Icon(Icons.shield, color: Colors.white),
                                ),
                                title: Text(opponent.label),
                                subtitle: Text(
                                  'Drag on pitch • x: ${opponent.x.toStringAsFixed(2)} • y: ${opponent.y.toStringAsFixed(2)}',
                                ),
                                trailing: IconButton(
                                  onPressed: () => state.removeOpponentPlayer(opponent.id),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InstructionPanel(
                      position: selected,
                      playerName: selectedPlayerName,
                      onChanged: (value) {
                        if (selected != null) state.updateInstructions(selected.id, value);
                      },
                      onClearAssignment: () {
                        if (selected != null) state.clearPositionAssignment(selected.id);
                      },
                    ),
                  ],
                ),
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: field),
                    const SizedBox(width: 20),
                    Expanded(flex: 3, child: sidePanel),
                  ],
                );
              }

              return Column(
                children: [
                  Expanded(flex: 5, child: field),
                  const SizedBox(height: 16),
                  Expanded(flex: 4, child: sidePanel),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}