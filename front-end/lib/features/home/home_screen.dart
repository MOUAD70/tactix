import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/state/app_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onNavigateToSection,
    required this.onOpenFormationBoard,
  });

  final ValueChanged<int> onNavigateToSection;
  final Future<void> Function() onOpenFormationBoard;

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Team overview', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Welcome back, ${state.coachName}. Your tactical board is ready for the next session.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _StatCard(label: 'Players', value: '${state.players.length}', icon: Icons.groups_2_outlined),
              _StatCard(label: 'Bench', value: '${state.benchPlayers.length}', icon: Icons.event_seat_outlined),
              _StatCard(label: 'Sessions', value: '${state.trainingSessions.length}', icon: Icons.fitness_center_outlined),
              _StatCard(
                label: 'Instructions',
                value: '${state.formation.positions.where((p) => p.instructions.isNotEmpty).length}',
                icon: Icons.assignment_outlined,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick navigation', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _QuickAction(
                        label: 'Formation',
                        icon: Icons.sports_soccer,
                        onTap: () {
                          onOpenFormationBoard();
                        },
                      ),
                      _QuickAction(label: 'Players', icon: Icons.groups, onTap: () => onNavigateToSection(2)),
                      _QuickAction(label: 'Training', icon: Icons.fitness_center, onTap: () => onNavigateToSection(3)),
                      _QuickAction(label: 'Profile', icon: Icons.person, onTap: () => onNavigateToSection(4)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recent training sessions', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  for (final session in state.trainingSessions)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(child: Icon(Icons.flag_outlined)),
                      title: Text(session.title),
                      subtitle: Text('${session.focusArea} • ${session.scheduleLabel}'),
                      trailing: Text('${session.durationMinutes} min'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: ListTile(
          leading: CircleAvatar(child: Icon(icon)),
          title: Text(value, style: Theme.of(context).textTheme.headlineSmall),
          subtitle: Text(label),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(onPressed: onTap, icon: Icon(icon), label: Text(label));
  }
}