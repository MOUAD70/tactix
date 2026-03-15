class FormationPositionModel {
  const FormationPositionModel({
    required this.id,
    required this.role,
    required this.x,
    required this.y,
  });

  final int id;
  final String role;
  final double x;
  final double y;

  FormationPositionModel copyWith({
    int? id,
    String? role,
    double? x,
    double? y,
  }) {
    return FormationPositionModel(
      id: id ?? this.id,
      role: role ?? this.role,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  factory FormationPositionModel.fromJson(Map<String, dynamic> json) {
    return FormationPositionModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      role: json['role'] as String? ?? '',
      x: (json['x'] is num ? (json['x'] as num).toDouble() : double.tryParse(json['x']?.toString() ?? '0') ?? 0),
      y: (json['y'] is num ? (json['y'] as num).toDouble() : double.tryParse(json['y']?.toString() ?? '0') ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'x': x,
      'y': y,
    };
  }
}
