import 'package:flutter/material.dart';

import 'package:flutter_application_1/features/formation/widgets/opponent_marker.dart';
import 'package:flutter_application_1/features/formation/widgets/player_marker.dart';
import 'package:flutter_application_1/models/opponent_player.dart';
import 'package:flutter_application_1/models/player_position.dart';

class FootballField extends StatelessWidget {
  static const String _positionDragPrefix = 'position:';

  const FootballField({
    super.key,
    required this.positions,
    required this.opponents,
    required this.resolvePlayerName,
    required this.onSelectPosition,
    required this.selectedPositionId,
    required this.onMovePosition,
    required this.onSnapPosition,
    required this.onAssignPlayerToPosition,
    required this.onSwapPlayersBetweenPositions,
    required this.onMoveOpponent,
  });

  final List<PlayerPosition> positions;
  final List<OpponentPlayer> opponents;
  final String Function(PlayerPosition position) resolvePlayerName;
  final ValueChanged<String> onSelectPosition;
  final String? selectedPositionId;
  final void Function(String positionId, double x, double y) onMovePosition;
  final ValueChanged<String> onSnapPosition;
  final void Function(int playerId, String positionId) onAssignPlayerToPosition;
  final void Function(String fromPositionId, String toPositionId) onSwapPlayersBetweenPositions;
  final void Function(String opponentId, double x, double y) onMoveOpponent;

  static const double _playerMarkerWidth = 72;
  static const double _playerMarkerHeight = 60;
  static const double _opponentMarkerWidth = 62;
  static const double _opponentMarkerHeight = 46;

  bool _isPositionPayload(String data) => data.startsWith(_positionDragPrefix);

  String _positionIdFromPayload(String data) => data.substring(_positionDragPrefix.length);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 1.5,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            return Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF166534), Color(0xFF14532D)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(painter: _PitchPainter()),
                ),
                for (final position in positions)
                  Positioned(
                    left: (width - _playerMarkerWidth) * position.x,
                    top: (height - _playerMarkerHeight) * position.y,
                    child: DragTarget<Object>(
                      onWillAcceptWithDetails: (details) {
                        final data = details.data;
                        if (data is String && _isPositionPayload(data)) {
                          return _positionIdFromPayload(data) != position.id;
                        }
                        return data is int; // bench player
                      },
                      onAcceptWithDetails: (details) {
                        final data = details.data;
                        if (data is String && _isPositionPayload(data)) {
                          onSwapPlayersBetweenPositions(_positionIdFromPayload(data), position.id);
                        } else if (data is int) {
                          onAssignPlayerToPosition(data, position.id);
                        }
                        onSelectPosition(position.id);
                      },
                      builder: (context, candidateData, rejectedData) {
                        final marker = GestureDetector(
                          onTap: () => onSelectPosition(position.id),
                          onPanUpdate: (details) {
                            final currentLeft = (width - _playerMarkerWidth) * position.x;
                            final currentTop = (height - _playerMarkerHeight) * position.y;
                            final nextLeft = (currentLeft + details.delta.dx)
                                .clamp(0.0, width - _playerMarkerWidth)
                                .toDouble();
                            final nextTop = (currentTop + details.delta.dy)
                                .clamp(0.0, height - _playerMarkerHeight)
                                .toDouble();
                            onMovePosition(
                              position.id,
                              nextLeft / (width - _playerMarkerWidth),
                              nextTop / (height - _playerMarkerHeight),
                            );
                          },
                          onPanEnd: (_) => onSnapPosition(position.id),
                          child: PlayerMarker(
                            label: position.label,
                            playerName: resolvePlayerName(position),
                            isSelected: position.id == selectedPositionId || candidateData.isNotEmpty,
                            onTap: () => onSelectPosition(position.id),
                          ),
                        );

                        if (!position.hasAssignedPlayer) {
                          return marker;
                        }

                        return LongPressDraggable<String>(
                          data: '$_positionDragPrefix${position.id}',
                          feedback: Material(
                            color: Colors.transparent,
                            child: PlayerMarker(
                              label: position.label,
                              playerName: resolvePlayerName(position),
                              isSelected: true,
                              onTap: () {},
                            ),
                          ),
                          childWhenDragging: Opacity(opacity: 0.35, child: marker),
                          child: marker,
                        );
                      },
                    ),
                  ),
                for (final opponent in opponents)
                  Positioned(
                    left: (width - _opponentMarkerWidth) * opponent.x,
                    top: (height - _opponentMarkerHeight) * opponent.y,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        final currentLeft = (width - _opponentMarkerWidth) * opponent.x;
                        final currentTop = (height - _opponentMarkerHeight) * opponent.y;
                        final nextLeft = (currentLeft + details.delta.dx)
                            .clamp(0.0, width - _opponentMarkerWidth)
                            .toDouble();
                        final nextTop = (currentTop + details.delta.dy)
                            .clamp(0.0, height - _opponentMarkerHeight)
                            .toDouble();
                        onMoveOpponent(
                          opponent.id,
                          nextLeft / (width - _opponentMarkerWidth),
                          nextTop / (height - _opponentMarkerHeight),
                        );
                      },
                      child: OpponentMarker(label: opponent.label),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(Rect.fromLTWH(12, 12, size.width - 24, size.height - 24), paint);
    canvas.drawLine(Offset(size.width / 2, 12), Offset(size.width / 2, size.height - 12), paint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 42, paint);
    canvas.drawRect(Rect.fromLTWH(12, size.height * 0.3, 80, size.height * 0.4), paint);
    canvas.drawRect(
      Rect.fromLTWH(size.width - 92, size.height * 0.3, 80, size.height * 0.4),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}