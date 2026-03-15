import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/app_error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import 'data/models/training_attendance_model.dart';
import 'data/models/training_session_model.dart';
import 'providers/training_provider.dart';

/// Full training session detail screen.
///
/// Displays session info, the attendance summary, and the full attendance list.
/// Allows submitting bulk attendance or updating a single player's status inline.
class TrainingDetailScreen extends ConsumerStatefulWidget {
  const TrainingDetailScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  ConsumerState<TrainingDetailScreen> createState() => _TrainingDetailScreenState();
}

class _TrainingDetailScreenState extends ConsumerState<TrainingDetailScreen> {
  // Local mutable copy of attendance for inline editing before bulk submit.
  List<TrainingAttendanceModel>? _localAttendance;
  bool _hasLocalChanges = false;

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(trainingSessionProvider(widget.sessionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session details'),
        actions: [
          if (_hasLocalChanges)
            FilledButton.icon(
              onPressed: _submitAttendance,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save'),
            ),
        ],
      ),
      body: sessionState.when(
        loading: () => const LoadingWidget(message: 'Loading session...'),
        error: (error, stack) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.read(trainingSessionProvider(widget.sessionId).notifier).loadSession(),
        ),
        data: (session) {
          if (session == null) {
            return const Center(child: Text('Session not found.'));
          }

          // Initialise local attendance once from the first data load.
          if (_localAttendance == null && session.attendance != null) {
            _localAttendance = List<TrainingAttendanceModel>.from(session.attendance!);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SessionHeader(session: session),
              const SizedBox(height: 16),
              if (session.summary != null) ...[
                _SummaryRow(summary: session.summary!),
                const SizedBox(height: 16),
              ],
              _AttendanceSection(
                attendance: _localAttendance ?? session.attendance ?? [],
                sessionIsLoading: sessionState.isLoading,
                onStatusChanged: _onStatusChanged,
                onBulkSubmit: _localAttendance != null ? _submitAttendance : null,
              ),
            ],
          );
        },
      ),
    );
  }

  void _onStatusChanged(TrainingAttendanceModel record, String newStatus) {
    final current = _localAttendance ?? [];
    setState(() {
      _localAttendance = current
          .map((item) =>
              item.playerId == record.playerId
                  ? TrainingAttendanceModel(
                      playerId: item.playerId,
                      name: item.name,
                      status: newStatus,
                      note: item.note,
                    )
                  : item)
          .toList(growable: false);
      _hasLocalChanges = true;
    });
  }

  Future<void> _submitAttendance() async {
    if (_localAttendance == null) return;
    await ref
        .read(trainingSessionProvider(widget.sessionId).notifier)
        .submitAttendance(_localAttendance!);
    if (mounted) {
      setState(() => _hasLocalChanges = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance saved.')),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _SessionHeader extends StatelessWidget {
  const _SessionHeader({required this.session});

  final TrainingSessionModel session;

  @override
  Widget build(BuildContext context) {
    final dateStr = session.sessionDate.toLocal().toIso8601String().split('T').first;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(session.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16),
                const SizedBox(width: 6),
                Text(dateStr, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            if (session.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(session.description, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.summary});

  final TrainingSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text('Attendance', style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            _SummaryChip(
              label: '${summary.present} Present',
              color: const Color(0xFF16A34A),
            ),
            const SizedBox(width: 8),
            _SummaryChip(
              label: '${summary.absent} Absent',
              color: const Color(0xFFDC2626),
            ),
            const SizedBox(width: 8),
            _SummaryChip(
              label: '${summary.late} Late',
              color: const Color(0xFFD97706),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

class _AttendanceSection extends StatelessWidget {
  const _AttendanceSection({
    required this.attendance,
    required this.sessionIsLoading,
    required this.onStatusChanged,
    this.onBulkSubmit,
  });

  final List<TrainingAttendanceModel> attendance;
  final bool sessionIsLoading;
  final void Function(TrainingAttendanceModel record, String newStatus) onStatusChanged;
  final VoidCallback? onBulkSubmit;

  @override
  Widget build(BuildContext context) {
    if (attendance.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text('No attendance records yet.', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(
                'Players will appear here once they are on your team roster.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  'Attendance (${attendance.length} players)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (onBulkSubmit != null) ...[
                  const Spacer(),
                  TextButton.icon(
                    onPressed: sessionIsLoading ? null : onBulkSubmit,
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Save all'),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          ...attendance.map(
            (record) => _AttendanceRow(
              record: record,
              onStatusChanged: (newStatus) => onStatusChanged(record, newStatus),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({required this.record, required this.onStatusChanged});

  final TrainingAttendanceModel record;
  final ValueChanged<String> onStatusChanged;

  static const _statuses = ['present', 'absent', 'late'];

  Color _statusColor(String status, BuildContext context) {
    switch (status) {
      case 'present':
        return const Color(0xFF16A34A);
      case 'absent':
        return const Color(0xFFDC2626);
      case 'late':
        return const Color(0xFFD97706);
      default:
        return Theme.of(context).colorScheme.onSurface;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'present':
        return Icons.check_circle_outline;
      case 'absent':
        return Icons.cancel_outlined;
      case 'late':
        return Icons.schedule_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(record.status, context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Icon(_statusIcon(record.status), color: color, size: 20),
      ),
      title: Text(record.name),
      subtitle: record.note != null && record.note!.isNotEmpty ? Text(record.note!) : null,
      trailing: DropdownButton<String>(
        value: record.status,
        underline: const SizedBox.shrink(),
        isDense: true,
        items: _statuses
            .map(
              (s) => DropdownMenuItem<String>(
                value: s,
                child: Text(
                  s[0].toUpperCase() + s.substring(1),
                  style: TextStyle(color: _statusColor(s, context), fontWeight: FontWeight.w600),
                ),
              ),
            )
            .toList(growable: false),
        onChanged: (value) {
          if (value != null && value != record.status) onStatusChanged(value);
        },
      ),
    );
  }
}
