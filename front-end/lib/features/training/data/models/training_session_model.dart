import 'package:flutter/foundation.dart';

import 'training_attendance_model.dart';

class TrainingSummary {
  const TrainingSummary({
    required this.total,
    required this.present,
    required this.absent,
    required this.late,
  });

  final int total;
  final int present;
  final int absent;
  final int late;

  factory TrainingSummary.fromJson(Map<String, dynamic> json) {
    return TrainingSummary(
      total: (json['total'] is int ? json['total'] as int : int.tryParse(json['total']?.toString() ?? '') ?? 0),
      present: (json['present'] is int ? json['present'] as int : int.tryParse(json['present']?.toString() ?? '') ?? 0),
      absent: (json['absent'] is int ? json['absent'] as int : int.tryParse(json['absent']?.toString() ?? '') ?? 0),
      late: (json['late'] is int ? json['late'] as int : int.tryParse(json['late']?.toString() ?? '') ?? 0),
    );
  }
}

class TrainingSessionModel {
  const TrainingSessionModel({
    required this.id,
    required this.teamId,
    required this.title,
    required this.description,
    required this.sessionDate,
    required this.createdAt,
    required this.updatedAt,
    this.summary,
    this.attendance,
  });

  final int id;
  final int teamId;
  final String title;
  final String description;
  final DateTime sessionDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TrainingSummary? summary;
  final List<TrainingAttendanceModel>? attendance;

  factory TrainingSessionModel.fromJson(Map<String, dynamic> json) {
    final attendance = <TrainingAttendanceModel>[];
    if (json['attendance'] is List) {
      attendance.addAll(
        (json['attendance'] as List)
            .whereType<Map<String, dynamic>>()
            .map(TrainingAttendanceModel.fromJson),
      );
    }

    return TrainingSessionModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      teamId: json['team_id'] is int ? json['team_id'] as int : int.tryParse(json['team_id']?.toString() ?? '') ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      sessionDate: DateTime.parse(json['session_date'] as String? ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] as String? ?? DateTime.now().toIso8601String()),
      summary: json['summary'] is Map<String, dynamic>
          ? TrainingSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
      attendance: attendance.isEmpty ? null : attendance,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'team_id': teamId,
      'title': title,
      'description': description,
      'session_date': sessionDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (summary != null)
        'summary': {
          'total': summary!.total,
          'present': summary!.present,
          'absent': summary!.absent,
          'late': summary!.late,
        },
      if (attendance != null)
        'attendance': attendance!.map((item) => item.toJson()).toList(growable: false),
    };
  }

  TrainingSessionModel copyWith({
    int? id,
    int? teamId,
    String? title,
    String? description,
    DateTime? sessionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    TrainingSummary? summary,
    List<TrainingAttendanceModel>? attendance,
  }) {
    return TrainingSessionModel(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      title: title ?? this.title,
      description: description ?? this.description,
      sessionDate: sessionDate ?? this.sessionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      summary: summary ?? this.summary,
      attendance: attendance ?? this.attendance,
    );
  }
}
