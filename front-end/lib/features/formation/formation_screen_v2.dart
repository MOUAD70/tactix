import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/app_error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import 'providers/formation_provider.dart';

class FormationScreenV2 extends ConsumerStatefulWidget {
  const FormationScreenV2({super.key});

  @override
  ConsumerState<FormationScreenV2> createState() => _FormationScreenV2State();
}

class _FormationScreenV2State extends ConsumerState<FormationScreenV2> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(formationNotifierProvider.notifier).loadFormations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final formationState = ref.watch(formationNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Formations')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: formationState.list.when(
          loading: () => const Center(child: LoadingWidget(message: 'Loading formations...')),
          error: (error, stack) => Center(
            child: AppErrorWidget(
              message: error.toString(),
              onRetry: () => ref.read(formationNotifierProvider.notifier).loadFormations(),
            ),
          ),
          data: (formations) {
            final activeFormation = formationState.active.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<int>(
                  value: activeFormation?.id,
                  decoration: const InputDecoration(labelText: 'Active formation'),
                  items: formations
                      .map(
                        (formation) => DropdownMenuItem(
                          value: formation.id,
                          child: Text(formation.name),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(formationNotifierProvider.notifier).selectFormation(value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: activeFormation == null
                      ? const Center(child: Text('Select a formation to view details.'))
                      : ListView.builder(
                          itemCount: activeFormation.positions.length,
                          itemBuilder: (context, index) {
                            final position = activeFormation.positions[index];
                            final isUpdating = formationState.updatingPositionIds.contains(position.id);

                            return ListTile(
                              title: Text(position.role),
                              subtitle: Text('x: ${position.x.toStringAsFixed(2)}, y: ${position.y.toStringAsFixed(2)}'),
                              trailing: isUpdating
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () async {
                                        final result = await showDialog<Offset?>(
                                          context: context,
                                          builder: (context) {
                                            final xController = TextEditingController(text: position.x.toString());
                                            final yController = TextEditingController(text: position.y.toString());

                                            return AlertDialog(
                                              title: const Text('Edit position'),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextField(
                                                    controller: xController,
                                                    decoration: const InputDecoration(labelText: 'X'),
                                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                  ),
                                                  TextField(
                                                    controller: yController,
                                                    decoration: const InputDecoration(labelText: 'Y'),
                                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(null),
                                                  child: const Text('Cancel'),
                                                ),
                                                FilledButton(
                                                  onPressed: () {
                                                    final parsedX = double.tryParse(xController.text);
                                                    final parsedY = double.tryParse(yController.text);
                                                    if (parsedX != null && parsedY != null) {
                                                      Navigator.of(context).pop(Offset(parsedX, parsedY));
                                                    }
                                                  },
                                                  child: const Text('Save'),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (result != null) {
                                          await ref.read(formationNotifierProvider.notifier).updatePosition(
                                                formationId: activeFormation.id,
                                                positionId: position.id,
                                                x: result.dx,
                                                y: result.dy,
                                              );
                                        }
                                      },
                                    ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
