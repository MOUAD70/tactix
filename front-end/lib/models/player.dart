enum PlayerRole {
  gk('GK'),
  lb('LB'),
  cb('CB'),
  rb('RB'),
  dm('DM'),
  cm('CM'),
  am('AM'),
  lw('LW'),
  rw('RW'),
  st('ST');

  const PlayerRole(this.label);

  final String label;
}

class Player {
  const Player({
    required this.id,
    required this.name,
    required this.jerseyNumber,
    required this.position,
  });

  final int id;
  final String name;
  final int jerseyNumber;
  final PlayerRole position;

  String get numberLabel => '#$jerseyNumber';

  Player copyWith({
    int? id,
    String? name,
    int? jerseyNumber,
    PlayerRole? position,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      position: position ?? this.position,
    );
  }
}