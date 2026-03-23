import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/app_error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import 'data/models/training_attendance_model.dart';
import 'data/models/training_session_model.dart';
import 'providers/training_provider.dart';
import 'widgets/training_tactical_board.dart';

class TrainingDetailScreen extends ConsumerStatefulWidget {
  const TrainingDetailScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  ConsumerState<TrainingDetailScreen> createState() => _TrainingDetailScreenState();
}

class _TrainingDetailScreenState extends ConsumerState<TrainingDetailScreen> {
  List<TrainingAttendanceModel>? _localAttendance;
  bool _hasLocalChanges = false;

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(trainingSessionProvider(widget.sessionId));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Session Details'),
          actions: [
            if (_hasLocalChanges)
              TextButton.icon(
                onPressed: _submitAttendance,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text('Save', style: TextStyle(color: Colors.white)),
              ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Attendance', icon: Icon(Icons.list_alt)),
              Tab(text: 'Tactical Board', icon: Icon(Icons.architecture)),
            ],
          ),
        ),
        body: sessionState.when(
          loading: () => const LoadingWidget(message: 'Loading session...'),
          error: (error, stack) => AppErrorWidget(
            message: error.toString(),
            onRetry: () => ref.read(trainingSessionProvider(widget.sessionId).notifier).loadSession(),
          ),
          data: (session) {
            if (session == null) return const Center(child: Text('Session not found.'));

            if (_localAttendance == null && session.attendance != null) {
              _localAttendance = List<TrainingAttendanceModel>.from(session.attendance!);
            }

            return TabBarView(
              children: [
                // التبويب الأول: التحضير
                _buildAttendanceList(session, sessionState.isLoading),
                // التبويب الثاني: الملعب التكتيكي
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: TrainingTacticalBoard(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAttendanceList(TrainingSessionModel session, bool isLoading) {
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
          sessionIsLoading: isLoading,
          onStatusChanged: _onStatusChanged,
          onBulkSubmit: _localAttendance != null ? _submitAttendance : null,
        ),
      ],
    );
  }

  void _onStatusChanged(TrainingAttendanceModel record, String newStatus) {
    final current = _localAttendance ?? [];
    setState(() {
      _localAttendance = current
          .map((item) => item.playerId == record.playerId
              ? TrainingAttendanceModel(
                  playerId: item.playerId,
                  name: item.name,
                  status: newStatus,
                  note: item.note,
                )
              : item)
          .toList();
      _hasLocalChanges = true;
    });
  }

  Future<void> _submitAttendance() async {
    if (_localAttendance == null) return;
    await ref.read(trainingSessionProvider(widget.sessionId).notifier).submitAttendance(_localAttendance!);
    if (mounted) {
      setState(() => _hasLocalChanges = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance saved.')));
    }
  }
}

// ── SUB-WIDGETS (التي كانت تسبب الخطأ) ──────────────────────────────────────

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
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 6),
                Text(dateStr),
              ],
            ),
            if (session.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(session.description),
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
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SummaryChip(label: 'Present: ${summary.present}', color: Colors.green),
            _SummaryChip(label: 'Absent: ${summary.absent}', color: Colors.red),
            _SummaryChip(label: 'Late: ${summary.late}', color: Colors.orange),
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
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
    if (attendance.isEmpty) return const Center(child: Text('No players found.'));

    return Card(
      child: Column(
        children: attendance.map((record) => _AttendanceRow(
          record: record,
          onStatusChanged: (val) => onStatusChanged(record, val),
        )).toList(),
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({required this.record, required this.onStatusChanged});
  final TrainingAttendanceModel record;
  final ValueChanged<String> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(record.name),
      trailing: DropdownButton<String>(
        value: record.status,
        items: ['present', 'absent', 'late'].map((s) => DropdownMenuItem(
          value: s,
          child: Text(s.toUpperCase()),
        )).toList(),
        onChanged: (val) => val != null ? onStatusChanged(val) : null,
      ),
    );
  }
}