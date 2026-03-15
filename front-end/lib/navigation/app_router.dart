import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/formation/formation_screen_v2.dart';
import '../features/home/home_screen.dart';
import '../features/players/player_detail_screen.dart';
import '../features/players/player_form_screen.dart';
import '../features/players/players_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/training/training_detail_screen.dart';
import '../features/training/training_screen.dart';

/// A simple [ChangeNotifier] that updates whenever authentication state changes.
///
/// This allows GoRouter to reevaluate redirects when login/logout happens.
class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier(Ref ref) {
    ref.listen<AsyncValue<dynamic>>(authProvider, (_, __) => notifyListeners());
  }
}

final authRefreshNotifierProvider = Provider<AuthRefreshNotifier>((ref) {
  return AuthRefreshNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(authRefreshNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState.asData?.value != null;

      final location = state.uri.toString();
      final isGoingToLogin = location == '/login';
      final isGoingToRegister = location == '/register';
      final isGoingToSplash = location == '/splash';

      if (!isAuthenticated) {
        // While we are checking auth state, keep the splash page.
        if (authState.isLoading) return '/splash';

        // If not authenticated, stay on login/register.
        if (isGoingToLogin || isGoingToRegister) return null;
        
        // Otherwise (including from splash), redirect to login
        return '/login';
      }

      // If authenticated, never show auth pages.
      if (isGoingToLogin || isGoingToRegister || isGoingToSplash) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/formations',
            builder: (context, state) => const FormationScreenV2(),
          ),
          GoRoute(
            path: '/players',
            builder: (context, state) => const PlayersScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const PlayerFormScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final idString = state.pathParameters['id'];
                  final id = idString != null ? int.tryParse(idString) : null;
                  return PlayerDetailScreen(playerId: id);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) {
                      final idString = state.pathParameters['id'];
                      final id = idString != null ? int.tryParse(idString) : null;
                      return PlayerFormScreen(playerId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/training',
            builder: (context, state) => const TrainingScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final idString = state.pathParameters['id'];
                  final id = idString != null ? int.tryParse(idString) : null;
                  return TrainingDetailScreen(sessionId: id ?? 0);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _tabRoutes = <String>[
    '/home',
    '/formations',
    '/players',
    '/training',
    '/profile',
  ];

  int _selectedIndex(String location) {
    final match = _tabRoutes.indexWhere((route) => location.startsWith(route));
    return match < 0 ? 0 : match;
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final selectedIndex =
        _selectedIndex(router.routerDelegate.currentConfiguration.uri.toString());

    return Scaffold(
      appBar: AppBar(title: const Text('Tactix')),
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          final route = _tabRoutes[index];
          final currentLocation =
              router.routerDelegate.currentConfiguration.uri.toString();
          if (route == currentLocation) return;
          router.go(route);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.sports_soccer_outlined), label: 'Formation'),
          NavigationDestination(icon: Icon(Icons.groups_2_outlined), label: 'Players'),
          NavigationDestination(icon: Icon(Icons.fitness_center_outlined), label: 'Training'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
