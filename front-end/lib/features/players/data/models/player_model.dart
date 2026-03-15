import 'package:flutter_application_1/models/player.dart';

class PlayerModel extends Player {
  const PlayerModel({
    required super.id,
    required super.name,
    required super.jerseyNumber,
    required super.position,
    this.teamId,
  });

  final int? teamId;

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    final positionString = json['position'] as String?;
    final position = PlayerRole.values.firstWhere(
      (role) => role.name == positionString || role.label.toLowerCase() == positionString?.toLowerCase(),
      orElse: () => PlayerRole.cm,
    );

    return PlayerModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String? ?? '',
      jerseyNumber: json['jersey_number'] is int
          ? json['jersey_number'] as int
          : int.tryParse(json['jersey_number']?.toString() ?? '') ?? 0,
      position: position,
      teamId: json['team_id'] is int ? json['team_id'] as int : int.tryParse(json['team_id']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'jersey_number': jerseyNumber,
      'position': position.name,
      if (teamId != null) 'team_id': teamId,
    };
  }
}
