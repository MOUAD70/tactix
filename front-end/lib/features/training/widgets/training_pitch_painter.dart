import 'package:flutter/material.dart';

/// Draws a football pitch inspired by the eFootball 2026 aesthetic:
/// alternating dark-green grass bands, a shimmer overlay that mimics
/// the glassmorphism "frosted field" look, and crisp white pitch lines.
///
/// Used exclusively inside [TrainingTacticalBoard] – isolated from the
/// Formation section's pitch painter.
class TrainingPitchPainter extends CustomPainter {
  const TrainingPitchPainter();

  // ── Grass colours ────────────────────────────────────────────────────────
  static const _band1 = Color(0xFF0B5226);
  static const _band2 = Color(0xFF094520);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Alternating grass bands
    const bands = 14;
    final bandPaint = Paint();
    for (int i = 0; i < bands; i++) {
      bandPaint.color = i.isEven ? _band1 : _band2;
      canvas.drawRect(
        Rect.fromLTWH(0, i * h / bands, w, h / bands),
        bandPaint,
      );
    }

    // 2. Subtle glassmorphism shimmer overlay
    final shimmerPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x08FFFFFF),
          Color(0x12FFFFFF),
          Color(0x06FFFFFF),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), shimmerPaint);

    // 3. Pitch lines
    final lp = Paint()
      ..color = Colors.white.withValues(alpha: 0.80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round;

    const m = 13.0; // margin from edge

    // Outer boundary
    canvas.drawRect(Rect.fromLTWH(m, m, w - 2 * m, h - 2 * m), lp);

    // Halfway line
    canvas.drawLine(Offset(m, h / 2), Offset(w - m, h / 2), lp);

    // Centre circle
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.13, lp);
    lp.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w / 2, h / 2), 3, lp);
    lp.style = PaintingStyle.stroke;

    // Penalty areas
    final bw = w * 0.58;
    final bd = h * 0.17;
    canvas.drawRect(Rect.fromLTWH((w - bw) / 2, m, bw, bd), lp); // top
    canvas.drawRect(Rect.fromLTWH((w - bw) / 2, h - m - bd, bw, bd), lp); // bot

    // Goal boxes
    final gw = w * 0.30;
    final gd = h * 0.07;
    canvas.drawRect(Rect.fromLTWH((w - gw) / 2, m, gw, gd), lp);
    canvas.drawRect(Rect.fromLTWH((w - gw) / 2, h - m - gd, gw, gd), lp);

    // Goals (outside boundary)
    final goalW = w * 0.18;
    const goalDepth = 9.0;
    canvas.drawRect(Rect.fromLTWH((w - goalW) / 2, m - goalDepth, goalW, goalDepth), lp);
    canvas.drawRect(Rect.fromLTWH((w - goalW) / 2, h - m, goalW, goalDepth), lp);

    // Penalty spots
    lp.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w / 2, m + bd * 0.62), 2.5, lp);
    canvas.drawCircle(Offset(w / 2, h - m - bd * 0.62), 2.5, lp);
    lp.style = PaintingStyle.stroke;
  }

  @override
  bool shouldRepaint(TrainingPitchPainter _) => false;
}

