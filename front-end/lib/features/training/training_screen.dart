import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/state/app_state.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Training sessions', style: Theme.of(context).textTheme.headlineSmall),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Training creation UI can be expanded next.')),
              ),
              icon: const Icon(Icons.add_task),
              label: const Text('Create Session'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: state.trainingSessions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final session = state.trainingSessions[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.sports_score_outlined)),
                  title: Text(session.title),
                  subtitle: Text('${session.focusArea} • ${session.description}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(session.scheduleLabel),
                      Text('${session.durationMinutes} min'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}