import 'package:flutter/material.dart';

import 'package:flutter_application_1/widgets/custom_button.dart';
import 'package:flutter_application_1/widgets/custom_input.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.onRegister,
    required this.onBackToLogin,
  });

  final void Function(
    String name,
    String email,
    String password,
    String role,
    String? teamId,
  ) onRegister;
  final VoidCallback onBackToLogin;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _teamIdController = TextEditingController();
  String _role = 'coach';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _teamIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Create Tactix account', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 20),
                      CustomInput(label: 'Name', controller: _nameController),
                      const SizedBox(height: 16),
                      CustomInput(label: 'Email', controller: _emailController),
                      const SizedBox(height: 16),
                      CustomInput(
                        label: 'Password',
                        controller: _passwordController,
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _role,
                        decoration: const InputDecoration(labelText: 'Role'),
                        items: const [
                          DropdownMenuItem(value: 'admin', child: Text('admin')),
                          DropdownMenuItem(value: 'coach', child: Text('coach')),
                        ],
                        onChanged: (value) => setState(() => _role = value ?? 'coach'),
                      ),
                      if (_role == 'coach') ...[
                        const SizedBox(height: 16),
                        CustomInput(label: 'Team ID', controller: _teamIdController),
                      ],
                      const SizedBox(height: 20),
                      CustomButton(
                        label: 'Register',
                        icon: Icons.app_registration,
                        onPressed: () => widget.onRegister(
                          _nameController.text.trim(),
                          _emailController.text.trim(),
                          _passwordController.text,
                          _role,
                          _role == 'coach' ? _teamIdController.text.trim() : null,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: widget.onBackToLogin,
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
    );
  }
}