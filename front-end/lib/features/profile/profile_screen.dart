import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  bool _initialized = false;

  void _ensureInitialized() {
    if (_initialized) return;
    final user = ref.read(authProvider).asData?.value;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _initialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _ensureInitialized();
    final user = ref.watch(authProvider).asData?.value;

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
                        Text(user == null ? 'Please login to see profile details.' : 'Update your account information below.'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CustomInput(label: 'Name', controller: _nameController),
              const SizedBox(height: 16),
              CustomInput(label: 'Email', controller: _emailController),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: 'Save Profile',
                      icon: Icons.save_outlined,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile updates are not synced with the server yet.')),
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
                      onPressed: () {
                        ref.read(authProvider.notifier).logout();
                      },
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
