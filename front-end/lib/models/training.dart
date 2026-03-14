class Training {
  const Training({
    required this.id,
    required this.title,
    required this.focusArea,
    required this.date,
    required this.description,
    required this.durationMinutes,
  });

  final String id;
  final String title;
  final String focusArea;
  final DateTime date;
  final String description;
  final int durationMinutes;

  String get scheduleLabel =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  Training copyWith({
    String? id,
    String? title,
    String? focusArea,
    DateTime? date,
    String? description,
    int? durationMinutes,
  }) {
    return Training(
      id: id ?? this.id,
      title: title ?? this.title,
      focusArea: focusArea ?? this.focusArea,
      date: date ?? this.date,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }
}