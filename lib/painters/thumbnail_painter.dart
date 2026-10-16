import 'package:flutter/material.dart';

class ThumbnailPainter extends CustomPainter {
  final List<int> pixels;
  final int gridWidth;
  final int gridHeight;
  final bool drawCheckerboard;

  const ThumbnailPainter({
    required this.pixels,
    required this.gridWidth,
    required this.gridHeight,
    this.drawCheckerboard = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (gridWidth <= 0 || gridHeight <= 0 || pixels.isEmpty) return;

    final cellW = size.width / gridWidth;
    final cellH = size.height / gridHeight;

    if (drawCheckerboard) {
      final p1 = Paint()..color = const Color(0xFFF7F5F0);
      final p2 = Paint()..color = const Color(0xFFEBE6DC);
      final sqSize = cellW < 4 ? 4.0 : cellW;
      final cols = (size.width / sqSize).ceil();
      final rows = (size.height / sqSize).ceil();

      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          final p = (r + c) % 2 == 0 ? p1 : p2;
          canvas.drawRect(
            Rect.fromLTWH(c * sqSize, r * sqSize, sqSize, sqSize),
            p,
          );
        }
      }
    }

    final pixelPaint = Paint()
      ..isAntiAlias = false
      ..style = PaintingStyle.fill;

    for (int y = 0; y < gridHeight; y++) {
      for (int x = 0; x < gridWidth; x++) {
        final idx = y * gridWidth + x;
        if (idx < pixels.length) {
          final val = pixels[idx];
          if ((val & 0xFF000000) != 0) {
            pixelPaint.color = Color(val);
            canvas.drawRect(
              Rect.fromLTWH(x * cellW, y * cellH, cellW, cellH),
              pixelPaint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant ThumbnailPainter oldDelegate) {
    return oldDelegate.pixels != pixels ||
        oldDelegate.gridWidth != gridWidth ||
        oldDelegate.gridHeight != gridHeight;
  }
}
