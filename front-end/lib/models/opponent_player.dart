class OpponentPlayer {
  const OpponentPlayer({
    required this.id,
    required this.label,
    required this.x,
    required this.y,
  });

  final String id;
  final String label;
  final double x;
  final double y;

  OpponentPlayer copyWith({String? id, String? label, double? x, double? y}) {
    return OpponentPlayer(
      id: id ?? this.id,
      label: label ?? this.label,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }
}