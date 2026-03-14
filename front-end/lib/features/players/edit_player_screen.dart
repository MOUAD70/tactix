import 'package:flutter/material.dart';

import 'package:flutter_application_1/models/player.dart';
import 'package:flutter_application_1/widgets/custom_button.dart';
import 'package:flutter_application_1/widgets/custom_input.dart';

class EditPlayerScreen extends StatefulWidget {
  const EditPlayerScreen({super.key, required this.player});

  final Player player;

  @override
  State<EditPlayerScreen> createState() => _EditPlayerScreenState();
}

class _EditPlayerScreenState extends State<EditPlayerScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _numberController;
  late PlayerRole _position;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.player.name);
    _numberController = TextEditingController(text: '${widget.player.jerseyNumber}');
    _position = widget.player.position;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Player')),
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
                    onChanged: (value) => setState(() => _position = value ?? widget.player.position),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    label: 'Update Player',
                    onPressed: () {
                      Navigator.of(context).pop(
                        widget.player.copyWith(
                          name: _nameController.text.trim(),
                          jerseyNumber: int.tryParse(_numberController.text) ?? widget.player.jerseyNumber,
                          position: _position,
                        ),
                      );
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