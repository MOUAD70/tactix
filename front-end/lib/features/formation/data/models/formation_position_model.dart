class FormationPositionModel {
  const FormationPositionModel({
    required this.id,
    required this.role,
    required this.x,
    required this.y,
    this.playerName = '',
    this.playerNumber = 10,
  });

  final int id;
  final String role;
  final double x;
  final double y;
  final String playerName;
  final int playerNumber;

  FormationPositionModel copyWith({
    int? id,
    String? role,
    double? x,
    double? y,
    String? playerName,
    int? playerNumber,
  }) {
    return FormationPositionModel(
      id: id ?? this.id,
      role: role ?? this.role,
      x: x ?? this.x,
      y: y ?? this.y,
      playerName: playerName ?? this.playerName,
      playerNumber: playerNumber ?? this.playerNumber,
    );
  }

  factory FormationPositionModel.fromJson(Map<String, dynamic> json) {
    return FormationPositionModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      role: json['role'] as String? ?? '',
      x: (json['x'] is num ? (json['x'] as num).toDouble() : double.tryParse(json['x']?.toString() ?? '0') ?? 0),
      y: (json['y'] is num ? (json['y'] as num).toDouble() : double.tryParse(json['y']?.toString() ?? '0') ?? 0),
      playerName: json['player_name'] as String? ?? '',
      playerNumber: json['player_number'] is int ? json['player_number'] as int : int.tryParse(json['player_number']?.toString() ?? '') ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'x': x.round(),
      'y': y.round(),
      'player_name': playerName,
      'player_number': playerNumber,
    };
  }
}
