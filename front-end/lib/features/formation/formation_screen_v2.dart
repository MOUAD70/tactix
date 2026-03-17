import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/app_error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import 'data/models/formation_model.dart';
import 'data/models/formation_position_model.dart';
import 'providers/formation_provider.dart';
import 'widgets/formation_pitch.dart';
import 'widgets/player_card.dart';
import 'constants/formation_presets.dart';

/// Default 4-3-3 positions used as initial layout when no formation is loaded.
const _default433 = [
  FormationPositionModel(id: 0, role: 'GK', x: 50.0, y: 5.0, playerName: 'Ederson', playerNumber: 31),
  FormationPositionModel(id: 0, role: 'LB', x: 15.0, y: 25.0, playerName: 'Aké', playerNumber: 6),
  FormationPositionModel(id: 0, role: 'CB', x: 35.0, y: 25.0, playerName: 'Dias', playerNumber: 3),
  FormationPositionModel(id: 0, role: 'CB', x: 65.0, y: 25.0, playerName: 'Stones', playerNumber: 5),
  FormationPositionModel(id: 0, role: 'RB', x: 85.0, y: 25.0, playerName: 'Walker', playerNumber: 2),
  FormationPositionModel(id: 0, role: 'CM', x: 25.0, y: 55.0, playerName: 'Silva', playerNumber: 20),
  FormationPositionModel(id: 0, role: 'CDM', x: 50.0, y: 45.0, playerName: 'Rodri', playerNumber: 16),
  FormationPositionModel(id: 0, role: 'CM', x: 75.0, y: 55.0, playerName: 'De Bruyne', playerNumber: 17),
  FormationPositionModel(id: 0, role: 'LW', x: 15.0, y: 80.0, playerName: 'Grealish', playerNumber: 10),
  FormationPositionModel(id: 0, role: 'ST', x: 50.0, y: 88.0, playerName: 'Haaland', playerNumber: 9),
  FormationPositionModel(id: 0, role: 'RW', x: 85.0, y: 80.0, playerName: 'Foden', playerNumber: 47),
];

class FormationScreenV2 extends ConsumerStatefulWidget {
  const FormationScreenV2({super.key});

  @override
  ConsumerState<FormationScreenV2> createState() => _FormationScreenV2State();
}

class _FormationScreenV2State extends ConsumerState<FormationScreenV2> {
  /// Local positions list — always shown on the pitch, even before API loads.
  List<FormationPositionModel> _localPositions = List.of(_default433);
  final TextEditingController _nameController = TextEditingController();
  String _selectedPreset = '4-3-3';
  bool _isSaving = false;

  List<Map<String, dynamic>> _demoSubstitutes = [
    {'name': 'Ortega', 'role': 'GK', 'number': 18},
    {'name': 'Alvarez', 'role': 'ST', 'number': 19},
    {'name': 'Kovacic', 'role': 'CM', 'number': 8},
    {'name': 'Gvardiol', 'role': 'CB', 'number': 24},
    {'name': 'Lewis', 'role': 'RB', 'number': 82},
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = 'New Formation';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(formationNotifierProvider.notifier).loadFormations();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// When an API formation is selected, sync local positions from it.
  void _syncFromActiveFormation(FormationModel formation) {
    setState(() {
      _localPositions = List.of(formation.positions);
    });
  }

  /// Move a position locally by list index (avoids id collision on default positions).
  void _moveLocalPosition(int index, double x, double y) {
    if (index < 0 || index >= _localPositions.length) return;
    setState(() {
      final updated = List<FormationPositionModel>.of(_localPositions);
      updated[index] = updated[index].copyWith(x: x, y: y);
      _localPositions = updated;
    });
  }

  /// After drag ends, persist the position to the backend if a formation is active.
  void _snapLocalPosition(int index) {
    if (index < 0 || index >= _localPositions.length) return;
    final activeFormation = ref.read(formationNotifierProvider).active.value;
    if (activeFormation == null) return;
    final pos = _localPositions[index];
    // Only persist if this position has a valid backend ID (not a local default).
    if (pos.id <= 0) return;
    ref.read(formationNotifierProvider.notifier).updatePosition(
          formationId: activeFormation.id,
          positionId: pos.id,
          x: pos.x,
          y: pos.y,
        );
  }

  void _handleSwapSubstitute(int pitchIndex, Map<String, dynamic> subData) {
    setState(() {
      final oldStarter = _localPositions[pitchIndex];
      
      // Update pitch position with sub data
      _localPositions[pitchIndex] = oldStarter.copyWith(
        playerName: subData['name'],
        playerNumber: subData['number'],
        role: subData['role'],
      );

      // Add old starter to substitutes and remove sub from substitutes
      final newSubs = List<Map<String, dynamic>>.from(_demoSubstitutes);
      newSubs.removeWhere((s) => s['name'] == subData['name'] && s['number'] == subData['number']);
      newSubs.add({
        'name': oldStarter.playerName,
        'role': oldStarter.role,
        'number': oldStarter.playerNumber,
      });
      _demoSubstitutes = newSubs;
    });
  }

  Future<void> _handleSaveFormation() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    if (!mounted) return;

    setState(() => _isSaving = true);
    try {
      await ref
          .read(formationNotifierProvider.notifier)
          .createFormation(name, _localPositions);

      // Reset name if successful
      _nameController.text = 'New Formation';
      
      // Sync local positions from newly created formation
      final active = ref.read(formationNotifierProvider).active.value;
      if (active != null && mounted) {
        _syncFromActiveFormation(active);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating formation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _onPresetChanged(String? preset) {
    if (preset == null) return;
    setState(() {
      _selectedPreset = preset;
      _localPositions = List.of(FormationPresets.presets[preset]!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final formationState = ref.watch(formationNotifierProvider);

    // Whenever a new active formation loads from API, sync our local pitch.
    ref.listen(formationNotifierProvider, (prev, next) {
      final prevActive = prev?.active.value;
      final nextActive = next.active.value;
      if (nextActive != null && nextActive != prevActive) {
        _syncFromActiveFormation(nextActive);
      }
    });

    final formations = formationState.list.value ?? [];
    final activeFormation = formationState.active.value;
    final isLoadingList = formationState.list.isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Active Selection ──────────────────────────────────────────
          if (isLoadingList)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LoadingWidget(message: 'Loading formations...'),
            )
          else if (formationState.list.hasError)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppErrorWidget(
                message: 'Could not load formations',
                onRetry: () => ref.read(formationNotifierProvider.notifier).loadFormations(),
              ),
            )
          else
            Row(
              children: [
                if (formations.isNotEmpty)
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: activeFormation?.id,
                      decoration: const InputDecoration(
                        labelText: 'Active formation',
                        isDense: true,
                      ),
                      items: formations
                          .map((f) => DropdownMenuItem(value: f.id, child: Text(f.name)))
                          .toList(growable: false),
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(formationNotifierProvider.notifier).selectFormation(value);
                        }
                      },
                    ),
                  )
                else
                  Expanded(
                    child: Text(
                      'No saved formations',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                if (_isSaving)
                  const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),

          const SizedBox(height: 20),

          // ── Terrain and Substitutes Row ────────────────────────────────
          // ── Terrain ──────────────────────────────────────────────────
          Center(
            child: FormationPitch(
              positions: _localPositions,
              onMovePosition: _moveLocalPosition,
              onSnapPosition: _snapLocalPosition,
              onSwapPlayer: _handleSwapSubstitute,
            ),
          ),

          const SizedBox(height: 20),

          // ── Substitutes Horizontal List (Bottom) ──────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Substitutes (Drag to Swap)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_demoSubstitutes.length, (index) {
                    final sub = _demoSubstitutes[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Draggable<Map<String, dynamic>>(
                        data: sub,
                        feedback: Material(
                          color: Colors.transparent,
                          child: PlayerCard(
                            position: sub['role'],
                            name: sub['name'],
                            number: sub['number'],
                            size: 45,
                            jerseyColor: Colors.amber, // Distinctive sub color
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: PlayerCard(
                            position: sub['role'],
                            name: sub['name'],
                            number: sub['number'],
                            size: 40,
                            jerseyColor: Colors.amber.shade200,
                          ),
                        ),
                        child: PlayerCard(
                          position: sub['role'],
                          name: sub['name'],
                          number: sub['number'],
                          size: 40, // Smaller subs
                          jerseyColor: Colors.amber, // Distinctive sub color
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Horizontal Controls (Preset, Name, Save) ─────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedPreset,
                      decoration: const InputDecoration(
                        labelText: 'Preset',
                        isDense: true,
                        prefixIcon: Icon(Icons.grid_view, size: 20),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      items: FormationPresets.presets.keys
                          .map((k) => DropdownMenuItem(value: k, child: Text(k, style: const TextStyle(fontSize: 12))))
                          .toList(),
                      onChanged: _onPresetChanged,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _nameController,
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        isDense: true,
                        prefixIcon: Icon(Icons.edit_note, size: 20),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isSaving ? null : _handleSaveFormation,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      minimumSize: const Size(0, 40),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Save', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
