import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// --- الإصلاح الدقيق للـ Import بناءً على صورتك ---
// بما أن ملف training_screen.dart موجود داخل مجلد training مباشرة
// وملف الـ provider موجود داخل training/providers
import 'providers/training_provider.dart'; 

// بما أن المجلدات المشتركة (shared) موجودة في lib/shared
import '../../shared/widgets/app_error_widget.dart';
import '../../shared/widgets/loading_widget.dart';

class TrainingScreen extends ConsumerWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // بمجرد حفظ هذا الملف، سيتعرف على trainingListProvider تلقائياً
    final trainingState = ref.watch(trainingListProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Training Sessions',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _showCreateSessionDialog(context, ref),
                icon: const Icon(Icons.add_task, size: 18),
                label: const Text('New Session'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: trainingState.when(
              data: (sessions) {
                if (sessions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sports_soccer_outlined,
                            size: 56, color: colorScheme.primary.withOpacity(0.4)),
                        const SizedBox(height: 12),
                        const Text('No training sessions yet.'),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: sessions.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    final dateLabel = session.sessionDate.toLocal().toString().split(' ').first;
                    return _SessionCard(
                      title: session.title,
                      description: session.description,
                      dateLabel: dateLabel,
                      presentLabel: '${session.summary.present}/${session.summary.total}',
                      onTap: () => context.push('/training/${session.id}'),
                    );
                  },
                );
              },
              loading: () => const LoadingWidget(message: 'Loading sessions…'),
              error: (error, _) => AppErrorWidget(
                message: error.toString(),
                onRetry: () => ref.read(trainingListProvider.notifier).loadSessions(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateSessionDialog(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime sessionDate = DateTime.now();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create training session'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text('Date: ${sessionDate.toLocal().toString().split(' ').first}'),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: sessionDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 30)),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) setDialogState(() => sessionDate = picked);
                          },
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) return;
                    try {
                      await ref.read(trainingListProvider.notifier).createSession(
                            title: titleController.text.trim(),
                            description: descriptionController.text.trim(),
                            date: sessionDate,
                          );
                      if (context.mounted) Navigator.of(context).pop();
                    } catch (e) {
                      debugPrint("Error creating session: $e");
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SessionCard extends StatelessWidget {
  final String title;
  final String description;
  final String dateLabel;
  final String? presentLabel;
  final VoidCallback onTap;

  const _SessionCard({
    required this.title,
    required this.description,
    required this.dateLabel,
    this.presentLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(title, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis),
                  ),
                  if (presentLabel != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Att: $presentLabel', 
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(dateLabel, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(description, 
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}