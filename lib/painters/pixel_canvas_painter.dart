import 'package:flutter/material.dart';
import '../models/pixel_canvas_data.dart';

class PixelCanvasPainter extends CustomPainter {
  final PixelCanvasData canvasData;
  final bool showGrid;
  final Color gridColor;

  PixelCanvasPainter({
    required this.canvasData,
    this.showGrid = true,
    this.gridColor = const Color(0x181E1E24),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cellW = size.width / canvasData.width;
    final double cellH = size.height / canvasData.height;

    final pixelPaint = Paint()
      ..isAntiAlias = false
      ..style = PaintingStyle.fill;

    // 1. Draw painted pixels
    for (int y = 0; y < canvasData.height; y++) {
      for (int x = 0; x < canvasData.width; x++) {
        final color = canvasData.getPixel(x, y);
        if (color.alpha > 0) {
          pixelPaint.color = color;
          final rect = Rect.fromLTWH(
            x * cellW,
            y * cellH,
            cellW,
            cellH,
          );
          canvas.drawRect(rect, pixelPaint);
        }
      }
    }

    // 2. Draw pixel grid overlay
    if (showGrid) {
      final gridPaint = Paint()
        ..color = gridColor
        ..strokeWidth = 0.75
        ..style = PaintingStyle.stroke;

      // Vertical lines
      for (int x = 0; x <= canvasData.width; x++) {
        final dx = x * cellW;
        canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), gridPaint);
      }

      // Horizontal lines
      for (int y = 0; y <= canvasData.height; y++) {
        final dy = y * cellH;
        canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PixelCanvasPainter oldDelegate) {
    return true; // CanvasData changes frequently during interaction
  }
}
