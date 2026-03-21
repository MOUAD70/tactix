import 'package:flutter/material.dart';

class PlayerCard extends StatelessWidget {
  final String position;
  final String name;
  final int number;
  final double size;
  final Color jerseyColor;
  final bool isSelected;
  final VoidCallback? onTap;

  const PlayerCard({
    super.key,
    required this.position,
    required this.name,
    this.number = 10,
    this.size = 70,
    this.jerseyColor = Colors.white,
    this.isSelected = false,
    this.onTap,
  });

  /// 🎨 Couleur selon le poste
  Color getPositionColor(String pos) {
    switch (pos) {
      case "GK":
        return Colors.orange;
      case "CB":
      case "LB":
      case "RB":
        return Colors.blue;
      case "CM":
      case "LM":
      case "RM":
        return Colors.green;
      case "AMF":
        return Colors.purple;
      case "ST":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final posColor = getPositionColor(position);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: isSelected ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                /// T-shirt
                ClipPath(
                  clipper: TShirtClipper(),
                  child: Container(
                    width: size,
                    height: size,
                    color: jerseyColor,
                  ),
                ),

                /// Numéro joueur
                Text(
                  number.toString(),
                  style: TextStyle(
                    fontSize: size * 0.28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                /// Position (top-left avec couleur)
                Positioned(
                  top: 2,
                  left: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: posColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      position,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            /// Nom joueur
            SizedBox(
              width: size + 10,
              child: Text(
                name,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 👕 Shape du maillot
class TShirtClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(size.width * 0.2, 0);
    path.lineTo(size.width * 0.35, 0);
    path.lineTo(size.width * 0.45, size.height * 0.15);
    path.lineTo(size.width * 0.55, size.height * 0.15);
    path.lineTo(size.width * 0.65, 0);
    path.lineTo(size.width * 0.8, 0);

    path.lineTo(size.width, size.height * 0.25);
    path.lineTo(size.width * 0.8, size.height * 0.4);

    path.lineTo(size.width * 0.8, size.height);
    path.lineTo(size.width * 0.2, size.height);

    path.lineTo(size.width * 0.2, size.height * 0.4);
    path.lineTo(0, size.height * 0.25);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
