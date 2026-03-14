import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/constants/app_constants.dart';
import 'package:flutter_application_1/core/state/app_state.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/features/auth/login_screen.dart';
import 'package:flutter_application_1/features/auth/register_screen.dart';
import 'package:flutter_application_1/features/formation/formation_screen.dart';
import 'package:flutter_application_1/features/home/home_screen.dart';
import 'package:flutter_application_1/features/players/players_screen.dart';
import 'package:flutter_application_1/features/profile/profile_screen.dart';
import 'package:flutter_application_1/features/training/training_screen.dart';
import 'package:flutter_application_1/navigation/bottom_navbar.dart';

void main() {
  runApp(const TactixApp());
}

enum AuthStage { login, register }

class TactixApp extends StatefulWidget {
  const TactixApp({super.key});

  @override
  State<TactixApp> createState() => _TactixAppState();
}

class _TactixAppState extends State<TactixApp> {
  final TactixAppState _appState = TactixAppState();
  AuthStage _authStage = AuthStage.login;

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: _appState,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        theme: AppTheme.buildTheme(),
        home: _AppContent(
          authStage: _authStage,
          onChangeAuthStage: (stage) => setState(() => _authStage = stage),
        ),
      ),
    );
  }
}

class _AppContent extends StatelessWidget {
  const _AppContent({
    required this.authStage,
    required this.onChangeAuthStage,
  });

  final AuthStage authStage;
  final ValueChanged<AuthStage> onChangeAuthStage;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    if (appState.isAuthenticated) {
      return MainShell(
        onLogout: () {
          appState.logout();
          onChangeAuthStage(AuthStage.login);
        },
      );
    }

    return authStage == AuthStage.login
        ? LoginScreen(
            onLogin: appState.login,
            onOpenRegister: () => onChangeAuthStage(AuthStage.register),
          )
        : RegisterScreen(
            onRegister: (name, email, password, role, teamId) {
              appState.register(
                name: name,
                email: email,
                password: password,
                role: role,
                teamId: teamId,
              );
              onChangeAuthStage(AuthStage.login);
            },
            onBackToLogin: () => onChangeAuthStage(AuthStage.login),
          );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  bool _isOpeningFormationBoard = false;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = <Widget>[
      HomeScreen(
        onNavigateToSection: _navigateToSection,
        onOpenFormationBoard: _openFormationBoard,
      ),
      const FormationScreen(),
      const PlayersScreen(),
      const TrainingScreen(),
      ProfileScreen(onLogout: widget.onLogout),
    ];
  }

  Future<void> _openFormationBoard() async {
    if (_isOpeningFormationBoard || !mounted) return;

    _isOpeningFormationBoard = true;

    try {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (context) => const FormationBoard()),
      );
    } finally {
      _isOpeningFormationBoard = false;
    }
  }

  void _navigateToSection(int index) {
    if (index == _currentIndex || index < 0 || index >= _screens.length) {
      return;
    }

    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppConstants.mainSections[_currentIndex])),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: IndexedStack(index: _currentIndex, children: _screens),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onDestinationSelected: _navigateToSection,
      ),
    );
  }
}
