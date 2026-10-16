import 'package:flutter/material.dart';

class CheckerboardPainter extends CustomPainter {
  final double squareSize;
  final Color color1;
  final Color color2;

  const CheckerboardPainter({
    this.squareSize = 12.0,
    this.color1 = const Color(0xFFF7F5F0),
    this.color2 = const Color(0xFFEBE6DC),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = color1;
    final paint2 = Paint()..color = color2;

    final cols = (size.width / squareSize).ceil();
    final rows = (size.height / squareSize).ceil();

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final paint = (r + c) % 2 == 0 ? paint1 : paint2;
        final rect = Rect.fromLTWH(
          c * squareSize,
          r * squareSize,
          squareSize,
          squareSize,
        );
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CheckerboardPainter oldDelegate) {
    return oldDelegate.squareSize != squareSize ||
        oldDelegate.color1 != color1 ||
        oldDelegate.color2 != color2;
  }
}
