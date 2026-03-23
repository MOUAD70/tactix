/// A local-only drill/exercise for a training session sketchboard.
///
/// This model is intentionally NOT connected to any API endpoint.
/// It is stored as part of the session's local preparation data and
/// serialised to JSON so it can be synced in a future backend sprint.
class DrillItem {
  DrillItem({
    required this.id,
    required this.name,
    this.description = '',
  });

  /// Unique local identifier (UUID-style string generated on creation).
  final String id;

  /// Short label for the drill, e.g. "Rondo 4v2".
  final String name;

  /// Optional longer description of the drill.
  final String description;

  DrillItem copyWith({String? name, String? description}) {
    return DrillItem(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
      };

  @override
  String toString() => name;
}

