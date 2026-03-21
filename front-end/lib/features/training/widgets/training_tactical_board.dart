import 'package:flutter/material.dart';

class TrainingTacticalBoard extends StatefulWidget {
  const TrainingTacticalBoard({super.key});

  @override
  State<TrainingTacticalBoard> createState() => _TrainingTacticalBoardState();
}

class _TrainingTacticalBoardState extends State<TrainingTacticalBoard> {
  // مواقع اللاعبين الافتراضية (نسبة مئوية لتناسب جميع الشاشات)
  final List<Map<String, dynamic>> _players = [
    {'id': 1, 'name': 'GK', 'pos': const Offset(0.5, 0.08)},
    {'id': 2, 'name': 'RB', 'pos': const Offset(0.8, 0.25)},
    {'id': 3, 'name': 'CB', 'pos': const Offset(0.6, 0.22)},
    {'id': 4, 'name': 'CB', 'pos': const Offset(0.4, 0.22)},
    {'id': 5, 'name': 'LB', 'pos': const Offset(0.2, 0.25)},
    {'id': 6, 'name': 'CDM', 'pos': const Offset(0.5, 0.40)},
    {'id': 7, 'name': 'CM', 'pos': const Offset(0.7, 0.55)},
    {'id': 8, 'name': 'CM', 'pos': const Offset(0.3, 0.55)},
    {'id': 9, 'name': 'RW', 'pos': const Offset(0.8, 0.80)},
    {'id': 10, 'name': 'ST', 'pos': const Offset(0.5, 0.85)},
    {'id': 11, 'name': 'LW', 'pos': const Offset(0.2, 0.80)},
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF064E3B), // Dark Green
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24, width: 2),
          ),
          child: Stack(
            children: [
              // رسم خطوط الملعب
              CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: PitchLinesPainter(),
              ),
              // اللاعبين
              ..._players.map((player) {
                return Positioned(
                  left: player['pos'].dx * constraints.maxWidth - 20,
                  top: player['pos'].dy * constraints.maxHeight - 20,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        player['pos'] = Offset(
                          (player['pos'].dx + details.delta.dx / constraints.maxWidth).clamp(0.05, 0.95),
                          (player['pos'].dy + details.delta.dy / constraints.maxHeight).clamp(0.05, 0.95),
                        );
                      });
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.redAccent,
                          child: Text(player['name'],
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class PitchLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // العشب (خطوط وهمية)
    final grassPaint = Paint()..color = Colors.white.withOpacity(0.05);
    for (int i = 0; i < 10; i++) {
      if (i % 2 == 0) {
        canvas.drawRect(
            Rect.fromLTWH(0, (size.height / 10) * i, size.width, size.height / 10),
            grassPaint);
      }
    }

    // الحدود والخطوط الأساسية
    canvas.drawRect(Offset.zero & size, paint);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 60, paint);
    
    // منطقة الجزاء
    canvas.drawRect(Rect.fromLTWH(size.width * 0.15, 0, size.width * 0.7, size.height * 0.18), paint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.15, size.height * 0.82, size.width * 0.7, size.height * 0.18), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}