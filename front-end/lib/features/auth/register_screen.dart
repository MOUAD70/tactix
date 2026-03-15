import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/exceptions.dart';
import '../../core/utils/validators.dart';
import '../../shared/widgets/loading_widget.dart';
import 'providers/auth_provider.dart';
import 'data/models/user_model.dart';
import 'data/repositories/auth_repository.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Team selection state
  List<TeamOption> _teams = [];
  bool _teamsLoading = true;
  String? _teamsError;
  int? _selectedTeamId;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    setState(() {
      _teamsLoading = true;
      _teamsError = null;
    });
    try {
      final teams = await ref.read(authRepositoryProvider).fetchTeams();
      if (mounted) {
        setState(() {
          _teams = teams;
          _teamsLoading = false;
          // Pre-select first team if available
          if (teams.isNotEmpty && _selectedTeamId == null) {
            _selectedTeamId = teams.first.id;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _teamsError = 'Failed to load teams. Please try again.';
          _teamsLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTeamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a team.')),
      );
      return;
    }

    await ref.read(authProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          teamId: _selectedTeamId!,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AsyncValue<UserModel?>>(authProvider, (previous, next) {
      if (next is AsyncData && next.value != null) {
        context.go('/home');
      }
      if (next is AsyncError) {
        final error = next.error;
        final message = error is ApiException ? error.message : error.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: authState.isLoading
                      ? const LoadingWidget(message: 'Creating your account...')
                      : Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create Tactix account',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 20),

                              // Name
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(labelText: 'Name'),
                                validator: (value) =>
                                    Validators.validateRequired(value, fieldName: 'Name'),
                              ),
                              const SizedBox(height: 16),

                              // Email
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(labelText: 'Email'),
                                keyboardType: TextInputType.emailAddress,
                                validator: Validators.validateEmail,
                              ),
                              const SizedBox(height: 16),

                              // Password
                              TextFormField(
                                controller: _passwordController,
                                decoration: const InputDecoration(labelText: 'Password'),
                                obscureText: true,
                                validator: Validators.validatePassword,
                              ),
                              const SizedBox(height: 16),

                              // Team dropdown — loaded from GET /teams
                              if (_teamsLoading)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Loading teams...'),
                                    ],
                                  ),
                                )
                              else if (_teamsError != null)
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _teamsError!,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.error,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: _loadTeams,
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                )
                              else
                                DropdownButtonFormField<int>(
                                  value: _selectedTeamId,
                                  decoration: const InputDecoration(labelText: 'Team'),
                                  items: _teams
                                      .map(
                                        (team) => DropdownMenuItem<int>(
                                          value: team.id,
                                          child: Text(team.name),
                                        ),
                                      )
                                      .toList(growable: false),
                                  onChanged: (value) =>
                                      setState(() => _selectedTeamId = value),
                                  validator: (value) =>
                                      value == null ? 'Please select a team.' : null,
                                ),

                              const SizedBox(height: 20),

                              ElevatedButton.icon(
                                onPressed: _onRegister,
                                icon: const Icon(Icons.app_registration),
                                label: const Text('Register'),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => context.go('/login'),
                                  child: const Text('Back to login'),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
