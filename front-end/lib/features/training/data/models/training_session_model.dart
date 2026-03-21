import 'training_attendance_model.dart';

class TrainingSummary {
  final int total;
  final int present;
  final int absent;
  final int late;

  TrainingSummary({required this.total, required this.present, required this.absent, required this.late});

  factory TrainingSummary.fromJson(Map<String, dynamic> json) {
    return TrainingSummary(
      total: json['total'] ?? 0,
      present: json['present'] ?? 0,
      absent: json['absent'] ?? 0,
      late: json['late'] ?? 0,
    );
  }
}

class TrainingSessionModel {
  final int id;
  final String title;
  final String description;
  final DateTime sessionDate;
  final List<TrainingAttendanceModel> attendance;
  final TrainingSummary summary;

  TrainingSessionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.sessionDate,
    required this.attendance,
    required this.summary,
  });

  factory TrainingSessionModel.fromJson(Map<String, dynamic> json) {
    return TrainingSessionModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      sessionDate: DateTime.parse(json['session_date'] ?? DateTime.now().toIso8601String()),
      attendance: (json['attendance'] as List? ?? [])
          .map((e) => TrainingAttendanceModel.fromJson(e))
          .toList(),
      summary: json['summary'] != null 
          ? TrainingSummary.fromJson(json['summary'])
          : TrainingSummary(total: 0, present: 0, absent: 0, late: 0),
    );
  }
}