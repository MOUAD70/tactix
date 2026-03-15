import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/app_error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import 'providers/training_provider.dart';

class TrainingScreen extends ConsumerWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainingState = ref.watch(trainingListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Training sessions', style: Theme.of(context).textTheme.headlineSmall),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => _showCreateSessionDialog(context, ref),
              icon: const Icon(Icons.add_task),
              label: const Text('Create Session'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: trainingState.when(
            data: (sessions) {
              if (sessions.isEmpty) {
                return Center(
                  child: Text(
                    'No training sessions yet. Create one to get started.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return ListView.separated(
                itemCount: sessions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return Card(
                    child: ListTile(
                      onTap: () => context.push('/training/${session.id}'),
                      leading: const CircleAvatar(child: Icon(Icons.sports_score_outlined)),
                      title: Text(session.title),
                      subtitle: Text(
                        session.description.isNotEmpty
                            ? session.description
                            : 'No description',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            session.sessionDate.toLocal().toIso8601String().split('T').first,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (session.summary != null)
                            Text(
                              '${session.summary!.present}/${session.summary!.total} present',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          const Icon(Icons.chevron_right, size: 18),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const LoadingWidget(message: 'Loading sessions...'),
            error: (error, stack) => AppErrorWidget(
              message: error.toString(),
              onRetry: () => ref.read(trainingListProvider.notifier).loadSessions(),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showCreateSessionDialog(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        // Phase 4 Fix 8: Use StatefulBuilder so the selected date can be
        // updated inside the dialog without the broken markNeedsBuild() hack.
        DateTime sessionDate = DateTime.now();

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create training session'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Date: ${sessionDate.toLocal().toIso8601String().split('T').first}',
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: sessionDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            // Use setDialogState (from StatefulBuilder) — not markNeedsBuild().
                            setDialogState(() => sessionDate = picked);
                          }
                        },
                        child: const Text('Change'),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) return;
                    await ref.read(trainingListProvider.notifier).createSession(
                          title: titleController.text.trim(),
                          description: descriptionController.text.trim(),
                          sessionDate: sessionDate,
                        );
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
  }
}
