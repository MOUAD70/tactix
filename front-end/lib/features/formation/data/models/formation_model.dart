import 'formation_position_model.dart';

class FormationModel {
  const FormationModel({
    required this.id,
    required this.name,
    required this.positions,
    this.teamId,
  });

  final int id;
  final String name;
  final List<FormationPositionModel> positions;
  final int? teamId;

  FormationModel copyWith({
    int? id,
    String? name,
    List<FormationPositionModel>? positions,
    int? teamId,
  }) {
    return FormationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      positions: positions ?? this.positions,
      teamId: teamId ?? this.teamId,
    );
  }

  factory FormationModel.fromJson(Map<String, dynamic> json) {
    final positions = <FormationPositionModel>[];
    if (json['positions'] is List) {
      positions.addAll(
        (json['positions'] as List)
            .whereType<Map<String, dynamic>>()
            .map(FormationPositionModel.fromJson),
      );
    }

    return FormationModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] as String? ?? '',
      positions: positions,
      teamId: json['team_id'] is int ? json['team_id'] as int : int.tryParse(json['team_id']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'positions': positions.map((p) => p.toJson()).toList(growable: false),
      if (teamId != null) 'team_id': teamId,
    };
  }
}
