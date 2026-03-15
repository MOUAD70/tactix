import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_application_1/models/player.dart';

import '../../core/utils/validators.dart';
import 'data/models/player_model.dart';
import 'providers/player_provider.dart';

class PlayerFormScreen extends ConsumerStatefulWidget {
  const PlayerFormScreen({
    super.key,
    this.playerId,
  });

  final int? playerId;

  @override
  ConsumerState<PlayerFormScreen> createState() => _PlayerFormScreenState();
}

class _PlayerFormScreenState extends ConsumerState<PlayerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _jerseyController;
  PlayerRole _selectedRole = PlayerRole.cm;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final playerId = widget.playerId;
    final players = ref.read(playerListProvider).asData?.value;
    final initialPlayer = players?.where((p) => p.id == playerId).firstOrNull;

    _nameController = TextEditingController(text: initialPlayer?.name ?? '');
    _jerseyController = TextEditingController(text: initialPlayer?.jerseyNumber.toString() ?? '');
    _selectedRole = initialPlayer?.position ?? PlayerRole.cm;

    _initialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _jerseyController.dispose();
    super.dispose();
  }

  Future<void> _savePlayer() async {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameController.text.trim();
    final jersey = int.tryParse(_jerseyController.text.trim()) ?? 0;

    try {
      final player = PlayerModel(
        id: widget.playerId ?? 0,
        name: name,
        jerseyNumber: jersey,
        position: _selectedRole,
      );

      if (widget.playerId != null) {
        await ref.read(playerListProvider.notifier).updatePlayer(player);
      } else {
        await ref.read(playerListProvider.notifier).addPlayer(player);
      }

      if (mounted) {
        context.pop();
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  void _tryInitializeFields() {
    if (_initialized || widget.playerId == null) return;

    final playersState = ref.watch(playerListProvider);
    final player = playersState.asData?.value.where((p) => p.id == widget.playerId).firstOrNull;

    if (player == null) return;

    _nameController.text = player.name;
    _jerseyController.text = player.jerseyNumber.toString();
    _selectedRole = player.position;
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    _tryInitializeFields();

    final isEditing = widget.playerId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Player' : 'Add Player'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: Validators.validateRequired,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jerseyController,
                decoration: const InputDecoration(labelText: 'Jersey number'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final number = int.tryParse(value ?? '');
                  if (number == null || number <= 0) {
                    return 'Please provide a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PlayerRole>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Position'),
                items: PlayerRole.values
                    .map(
                      (role) => DropdownMenuItem(value: role, child: Text(role.label)),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedRole = value);
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _savePlayer,
                icon: const Icon(Icons.save),
                label: Text(isEditing ? 'Save changes' : 'Create player'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
