import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/state/app_state.dart';
import 'package:flutter_application_1/widgets/custom_button.dart';
import 'package:flutter_application_1/widgets/custom_input.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController? _nameController;
  TextEditingController? _emailController;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final state = AppStateScope.of(context);
    _nameController = TextEditingController(text: state.coachName);
    _emailController = TextEditingController(text: state.coachEmail);
    _initialized = true;
  }

  @override
  void dispose() {
    _nameController?.dispose();
    _emailController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return SingleChildScrollView(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(radius: 34, child: Icon(Icons.person, size: 34)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Coach profile', style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 4),
                        const Text('Frontend-only profile management for now.'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CustomInput(label: 'Name', controller: _nameController!),
              const SizedBox(height: 16),
              CustomInput(label: 'Email', controller: _emailController!),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: 'Save Profile',
                      icon: Icons.save_outlined,
                      onPressed: () {
                        state.updateCoachProfile(
                          name: _nameController!.text.trim(),
                          email: _emailController!.text.trim(),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile updated locally.')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      label: 'Logout',
                      icon: Icons.logout,
                      isPrimary: false,
                      onPressed: widget.onLogout,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}