import 'package:flutter/material.dart';

import '../data/models/formation_position_model.dart';
import 'player_card.dart';

class FormationPitch extends StatelessWidget {
  const FormationPitch({
    super.key,
    required this.positions,
    required this.onMovePosition,
    required this.onSnapPosition,
    required this.onSwapPlayer,
  });

  final List<FormationPositionModel> positions;

  /// Called continuously while dragging. [index] is the list index of the
  /// moved position. [x] and [y] are in the 0–100 backend scale.
  final void Function(int index, double x, double y) onMovePosition;

  /// Called when the drag ends. [index] is the list index of the position.
  final ValueChanged<int> onSnapPosition;

  /// Called when a player is dropped onto a position.
  /// [index] is the index of the target position on the pitch.
  /// [playerData] is the data of the player being dropped.
  final void Function(int index, Map<String, dynamic> playerData) onSwapPlayer;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    // Portrait orientation on mobile (< 720 px wide), landscape on desktop/tablet.
    final isPortrait = screenW < 720;

    return Center(
      child: AspectRatio(
        aspectRatio: isPortrait ? 2 / 3 : 3 / 2,
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: _buildPitch(context, isPortrait: isPortrait),
        ),
      ),
    );
  }

  Widget _buildPitch(BuildContext context, {required bool isPortrait}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Stack(
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1a7a3e), Color(0xFF145c2e)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Pitch lines
            Positioned.fill(
              child: CustomPaint(
                painter: _PitchPainter(isPortrait: isPortrait),
              ),
            ),
            // Player markers
            for (int i = 0; i < positions.length; i++)
              _buildMarker(i, w, h, isPortrait),
          ],
        );
      },
    );
  }

  Widget _buildMarker(int index, double w, double h, bool isPortrait) {
    final position = positions[index];
    final markerSize = isPortrait ? 45.0 : 65.0; // Slightly smaller markers
    final markerW = markerSize + 10;
    final markerH = markerSize + 25;

    // Map 0-100 coords to pixel positions.
    // In portrait: X is horizontal, Y is vertical.
    // User requested GK (y=0 in data) to be at the bottom.
    final xPercent = position.x / 100;
    final yPercent = isPortrait ? (1 - position.y / 100) : (position.y / 100);

    final left = (w - markerW) * xPercent;
    final top = (h - markerH) * yPercent;

    return Positioned(
      left: left,
      top: top,
      child: DragTarget<Map<String, dynamic>>(
        onAcceptWithDetails: (details) {
          onSwapPlayer(index, details.data);
        },
        builder: (context, candidateData, rejectedData) {
          return Opacity(
            opacity: candidateData.isNotEmpty ? 0.7 : 1.0,
            child: GestureDetector(
              onPanUpdate: (details) {
                final curLeft = (w - markerW) * xPercent;
                final curTop = (h - markerH) * yPercent;
                final nextLeft = (curLeft + details.delta.dx).clamp(0.0, w - markerW);
                final nextTop = (curTop + details.delta.dy).clamp(0.0, h - markerH);
                
                final newX = (nextLeft / (w - markerW)) * 100;
                double newY = (nextTop / (h - markerH)) * 100;
                if (isPortrait) newY = 100 - newY;
                
                onMovePosition(index, newX, newY);
              },
              onPanEnd: (_) => onSnapPosition(index),
              child: PlayerCard(
                position: position.role,
                name: position.playerName,
                number: position.playerNumber,
                size: markerSize,
                isSelected: candidateData.isNotEmpty,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Draws pitch lines. Portrait mode: center line is horizontal, penalty boxes
/// are at top and bottom. Landscape mode: center line is vertical, boxes on sides.
class _PitchPainter extends CustomPainter {
  const _PitchPainter({required this.isPortrait});

  final bool isPortrait;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // --- Draw 12 terrain bands ---
    final bandPaint = Paint();
    final int bands = 12;
    for (int i = 0; i < bands; i++) {
      bandPaint.color = i % 2 == 0 
          ? const Color(0xFF1a7a3e) 
          : const Color(0xFF145c2e).withValues(alpha: 0.8);
      
      if (isPortrait) {
        final bandHeight = h / bands;
        canvas.drawRect(Rect.fromLTWH(0, i * bandHeight, w, bandHeight), bandPaint);
      } else {
        final bandWidth = w / bands;
        canvas.drawRect(Rect.fromLTWH(i * bandWidth, 0, bandWidth, h), bandPaint);
      }
    }

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    const margin = 10.0;
    const boxDepth = 70.0; // depth of penalty box from goal line
    const boxWidth = 180.0; // width of penalty box

    if (isPortrait) {
      // ── Portrait pitch (GK at bottom) ───────────────────────────────────
      // Outer boundary
      canvas.drawRect(Rect.fromLTWH(margin, margin, w - 2 * margin, h - 2 * margin), paint);
      // Horizontal center line
      canvas.drawLine(Offset(margin, h / 2), Offset(w - margin, h / 2), paint);
      // Center circle
      canvas.drawCircle(Offset(w / 2, h / 2), 40, paint);
      // Center dot
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(w / 2, h / 2), 3, paint);
      paint.style = PaintingStyle.stroke;

      // Bottom penalty box (GK end - y=0)
      final bw = (boxWidth).clamp(0.0, w - 2 * margin);
      final bdClamped = boxDepth.clamp(0.0, h / 2 - margin);
      canvas.drawRect(
        Rect.fromLTWH((w - bw) / 2, h - margin - bdClamped, bw, bdClamped),
        paint,
      );
      
      // Top penalty box (ST/Attacker end - y=100)
      canvas.drawRect(
        Rect.fromLTWH((w - bw) / 2, margin, bw, bdClamped),
        paint,
      );

      // Goals
      final gw = (bw * 0.38).clamp(0.0, bw);
      final gd = 12.0;
      canvas.drawRect(Rect.fromLTWH((w - gw) / 2, h - margin, gw, gd), paint); // Bottom goal
      canvas.drawRect(Rect.fromLTWH((w - gw) / 2, margin - gd, gw, gd), paint); // Top goal
    } else {
      // ── Landscape pitch ────────────────────────────────────────────────
      // Outer boundary
      canvas.drawRect(Rect.fromLTWH(margin, margin, w - 2 * margin, h - 2 * margin), paint);
      // Vertical center line
      canvas.drawLine(Offset(w / 2, margin), Offset(w / 2, h - margin), paint);
      // Center circle
      canvas.drawCircle(Offset(w / 2, h / 2), 42, paint);
      // Center dot
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(w / 2, h / 2), 3, paint);
      paint.style = PaintingStyle.stroke;
      // Left penalty box
      final bh = (boxWidth).clamp(0.0, h - 2 * margin);
      final bd = boxDepth.clamp(0.0, w / 2 - margin);
      canvas.drawRect(Rect.fromLTWH(margin, (h - bh) / 2, bd, bh), paint);
      // Right penalty box
      canvas.drawRect(Rect.fromLTWH(w - margin - bd, (h - bh) / 2, bd, bh), paint);
      // Goals
      final gh = (bh * 0.38).clamp(0.0, bh);
      final gd = 10.0;
      canvas.drawRect(Rect.fromLTWH(margin - gd, (h - gh) / 2, gd, gh), paint);
      canvas.drawRect(Rect.fromLTWH(w - margin, (h - gh) / 2, gd, gh), paint);
    }
  }

  @override
  bool shouldRepaint(_PitchPainter old) => old.isPortrait != isPortrait;
}

