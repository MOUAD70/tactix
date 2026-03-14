import 'package:flutter/material.dart';

import 'package:flutter_application_1/models/player.dart';
import 'package:flutter_application_1/widgets/custom_button.dart';
import 'package:flutter_application_1/widgets/custom_input.dart';

class AddPlayerScreen extends StatefulWidget {
  const AddPlayerScreen({super.key});

  @override
  State<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  PlayerRole _position = PlayerRole.cm;

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Player')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomInput(label: 'Name', controller: _nameController),
                  const SizedBox(height: 16),
                  CustomInput(
                    label: 'Jersey Number',
                    controller: _numberController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<PlayerRole>(
                    initialValue: _position,
                    decoration: const InputDecoration(labelText: 'Position'),
                    items: PlayerRole.values
                        .map((role) => DropdownMenuItem(value: role, child: Text(role.label)))
                        .toList(growable: false),
                    onChanged: (value) => setState(() => _position = value ?? PlayerRole.cm),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    label: 'Save Player',
                    onPressed: () {
                      final player = Player(
                        id: DateTime.now().microsecondsSinceEpoch.toString(),
                        name: _nameController.text.trim(),
                        jerseyNumber: int.tryParse(_numberController.text) ?? 0,
                        position: _position,
                      );
                      Navigator.of(context).pop(player);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}