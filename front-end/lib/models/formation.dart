import 'package:flutter_application_1/models/player_position.dart';

class Formation {
  const Formation({
    required this.id,
    required this.name,
    required this.schemeId,
    required this.positions,
    this.isPreset = true,
  });

  final String id;
  final String name;
  final String schemeId;
  final List<PlayerPosition> positions;
  final bool isPreset;

  PlayerPosition? findPosition(String id) {
    for (final position in positions) {
      if (position.id == id) return position;
    }
    return null;
  }

  Formation copyWith({
    String? id,
    String? name,
    String? schemeId,
    List<PlayerPosition>? positions,
    bool? isPreset,
  }) {
    return Formation(
      id: id ?? this.id,
      name: name ?? this.name,
      schemeId: schemeId ?? this.schemeId,
      positions: positions ?? this.positions,
      isPreset: isPreset ?? this.isPreset,
    );
  }

  static List<PlayerPosition> default433Positions([List<int> playerIds = const <int>[]]) {
    int? at(int index) => index < playerIds.length ? playerIds[index] : null;

    return <PlayerPosition>[
      PlayerPosition(id: 'gk', label: 'GK', x: 0.50, y: 0.92, playerId: at(0)),
      PlayerPosition(id: 'lb', label: 'LB', x: 0.16, y: 0.76, playerId: at(1)),
      PlayerPosition(id: 'lcb', label: 'CB', x: 0.36, y: 0.78, playerId: at(2)),
      PlayerPosition(id: 'rcb', label: 'CB', x: 0.64, y: 0.78, playerId: at(3)),
      PlayerPosition(id: 'rb', label: 'RB', x: 0.84, y: 0.76, playerId: at(4)),
      PlayerPosition(id: 'cm1', label: 'CM', x: 0.28, y: 0.56, playerId: at(5)),
      PlayerPosition(id: 'cm2', label: 'CM', x: 0.50, y: 0.50, playerId: at(6)),
      PlayerPosition(id: 'cm3', label: 'CM', x: 0.72, y: 0.56, playerId: at(7)),
      PlayerPosition(id: 'lw', label: 'LW', x: 0.18, y: 0.26, playerId: at(8)),
      PlayerPosition(id: 'st', label: 'ST', x: 0.50, y: 0.18, playerId: at(9)),
      PlayerPosition(id: 'rw', label: 'RW', x: 0.82, y: 0.26, playerId: at(10)),
    ];
  }

  static List<PlayerPosition> default4231Positions([List<int> playerIds = const <int>[]]) {
    int? at(int index) => index < playerIds.length ? playerIds[index] : null;

    return <PlayerPosition>[
      PlayerPosition(id: 'gk', label: 'GK', x: 0.50, y: 0.92, playerId: at(0)),
      PlayerPosition(id: 'lb', label: 'LB', x: 0.16, y: 0.78, playerId: at(1)),
      PlayerPosition(id: 'lcb', label: 'CB', x: 0.36, y: 0.80, playerId: at(2)),
      PlayerPosition(id: 'rcb', label: 'CB', x: 0.64, y: 0.80, playerId: at(3)),
      PlayerPosition(id: 'rb', label: 'RB', x: 0.84, y: 0.78, playerId: at(4)),
      PlayerPosition(id: 'dm1', label: 'DM', x: 0.40, y: 0.62, playerId: at(5)),
      PlayerPosition(id: 'dm2', label: 'DM', x: 0.60, y: 0.62, playerId: at(6)),
      PlayerPosition(id: 'lw', label: 'LW', x: 0.18, y: 0.34, playerId: at(7)),
      PlayerPosition(id: 'am', label: 'AM', x: 0.50, y: 0.42, playerId: at(8)),
      PlayerPosition(id: 'rw', label: 'RW', x: 0.82, y: 0.34, playerId: at(9)),
      PlayerPosition(id: 'st', label: 'ST', x: 0.50, y: 0.18, playerId: at(10)),
    ];
  }

  static List<PlayerPosition> default352Positions([List<int> playerIds = const <int>[]]) {
    int? at(int index) => index < playerIds.length ? playerIds[index] : null;

    return <PlayerPosition>[
      PlayerPosition(id: 'gk', label: 'GK', x: 0.50, y: 0.92, playerId: at(0)),
      PlayerPosition(id: 'lcb', label: 'CB', x: 0.28, y: 0.80, playerId: at(1)),
      PlayerPosition(id: 'cb', label: 'CB', x: 0.50, y: 0.83, playerId: at(2)),
      PlayerPosition(id: 'rcb', label: 'CB', x: 0.72, y: 0.80, playerId: at(3)),
      PlayerPosition(id: 'lwb', label: 'LWB', x: 0.12, y: 0.56, playerId: at(4)),
      PlayerPosition(id: 'cm1', label: 'CM', x: 0.34, y: 0.56, playerId: at(5)),
      PlayerPosition(id: 'cm2', label: 'CM', x: 0.50, y: 0.48, playerId: at(6)),
      PlayerPosition(id: 'cm3', label: 'CM', x: 0.66, y: 0.56, playerId: at(7)),
      PlayerPosition(id: 'rwb', label: 'RWB', x: 0.88, y: 0.56, playerId: at(8)),
      PlayerPosition(id: 'st1', label: 'ST', x: 0.40, y: 0.22, playerId: at(9)),
      PlayerPosition(id: 'st2', label: 'ST', x: 0.60, y: 0.22, playerId: at(10)),
    ];
  }

  static List<PlayerPosition> defaultPositionsForScheme(
    String schemeId, [
    List<int> playerIds = const <int>[],
  ]) {
    switch (schemeId) {
      case '4-2-3-1':
        return default4231Positions(playerIds);
      case '3-5-2':
        return default352Positions(playerIds);
      case '4-3-3':
      default:
        return default433Positions(playerIds);
    }
  }

  static Formation preset(String schemeId, List<int> playerIds) {
    return Formation(
      id: schemeId,
      name: schemeId,
      schemeId: schemeId,
      positions: defaultPositionsForScheme(schemeId, playerIds),
    );
  }

  static List<Formation> presetSamples(List<int> playerIds) {
    return <Formation>[
      preset('4-3-3', playerIds),
      preset('4-2-3-1', playerIds),
      preset('3-5-2', playerIds),
    ];
  }

  factory Formation.sample433(List<int> playerIds) {
    return Formation(
      id: '4-3-3',
      name: '4-3-3',
      schemeId: '4-3-3',
      positions: default433Positions(playerIds),
    );
  }
}