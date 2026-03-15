import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/providers/auth_provider.dart';
import '../formation/providers/formation_provider.dart';
import '../players/providers/player_provider.dart';
import '../training/providers/training_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final playersState = ref.watch(playerListProvider);
    final trainingsState = ref.watch(trainingListProvider);
    final formationsState = ref.watch(formationNotifierProvider);

    final coachName = authState.asData?.value?.name ?? 'Coach';
    final playerCount = playersState.asData?.value.length ?? 0;
    final trainingCount = trainingsState.asData?.value.length ?? 0;
    final formationCount = formationsState.list.asData?.value.length ?? 0;

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
                  Text('Welcome back, $coachName. Your tactical board is ready for the next session.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _StatCard(label: 'Players', value: '$playerCount', icon: Icons.groups_2_outlined),
              _StatCard(label: 'Formations', value: '$formationCount', icon: Icons.sports_soccer_outlined),
              _StatCard(label: 'Sessions', value: '$trainingCount', icon: Icons.fitness_center_outlined),
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
                        onTap: () => context.go('/formations'),
                      ),
                      _QuickAction(label: 'Players', icon: Icons.groups, onTap: () => context.go('/players')),
                      _QuickAction(label: 'Training', icon: Icons.fitness_center, onTap: () => context.go('/training')),
                      _QuickAction(label: 'Profile', icon: Icons.person, onTap: () => context.go('/profile')),
                    ],
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
