import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/providers/auth_provider.dart';
import '../formation/providers/formation_provider.dart';
import '../players/providers/player_provider.dart';
import '../training/providers/training_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  int _getCrossAxisCount(double width) {
    if (width < 600) return 1; // 📱 mobile
    if (width < 1000) return 2; // 📲 tablet
    return 3; // 💻 desktop
  }

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Team Overview',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome back, $coachName ⚽',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// STATS GRID
              GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
                children: [
                  _StatCard(
                    label: 'Players',
                    value: '$playerCount',
                    icon: Icons.groups_2_outlined,
                    gradient: [Colors.blue, Colors.blueAccent],
                  ),
                  _StatCard(
                    label: 'Formations',
                    value: '$formationCount',
                    icon: Icons.sports_soccer_outlined,
                    gradient: [Colors.green, Colors.lightGreen],
                  ),
                  _StatCard(
                    label: 'Sessions',
                    value: '$trainingCount',
                    icon: Icons.fitness_center_outlined,
                    gradient: [Colors.orange, Colors.deepOrange],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// QUICK ACTIONS
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quick Navigation',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _QuickAction(
                          label: 'Formation',
                          icon: Icons.sports_soccer,
                          onTap: () => context.go('/formations'),
                        ),
                        _QuickAction(
                          label: 'Players',
                          icon: Icons.groups,
                          onTap: () => context.go('/players'),
                        ),
                        _QuickAction(
                          label: 'Training',
                          icon: Icons.fitness_center,
                          onTap: () => context.go('/training'),
                        ),
                        _QuickAction(
                          label: 'Profile',
                          icon: Icons.person,
                          onTap: () => context.go('/profile'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}




class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  final String label;
  final String value;
  final IconData icon;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(icon, color: gradient.first),
        ),
        title: Text(
          value,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          label,
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}



class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}