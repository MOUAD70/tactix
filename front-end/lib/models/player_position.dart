const Object _playerIdSentinel = Object();

class PlayerPosition {
  const PlayerPosition({
    required this.id,
    required this.label,
    required this.x,
    required this.y,
    this.playerId,
    this.instructions = '',
  });

  final String id;
  final String label;
  final double x;
  final double y;
  final String? playerId;
  final String instructions;

  bool get hasAssignedPlayer => playerId != null;

  PlayerPosition copyWith({
    String? id,
    String? label,
    double? x,
    double? y,
    Object? playerId = _playerIdSentinel,
    String? instructions,
  }) {
    return PlayerPosition(
      id: id ?? this.id,
      label: label ?? this.label,
      x: x ?? this.x,
      y: y ?? this.y,
      playerId: identical(playerId, _playerIdSentinel) ? this.playerId : playerId as String?,
      instructions: instructions ?? this.instructions,
    );
  }
}