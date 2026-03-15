class TrainingAttendanceModel {
  const TrainingAttendanceModel({
    required this.playerId,
    required this.name,
    required this.status,
    this.note,
  });

  final int playerId;
  final String name;
  final String status;
  final String? note;

  factory TrainingAttendanceModel.fromJson(Map<String, dynamic> json) {
    return TrainingAttendanceModel(
      playerId: json['player_id'] is int ? json['player_id'] as int : int.tryParse(json['player_id']?.toString() ?? '') ?? 0,
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? '',
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'player_id': playerId,
      'status': status,
      if (note != null) 'note': note,
    };
  }
}
