import 'dart:collection';
import 'package:flutter/material.dart';

class PixelCanvasData {
  final int width;
  final int height;
  final List<int> _pixels; // 0xAARRGGBB format; 0x00000000 is transparent

  PixelCanvasData({
    required this.width,
    required this.height,
    List<int>? initialPixels,
  }) : _pixels = initialPixels != null
            ? List<int>.from(initialPixels)
            : List<int>.filled(width * height, 0);

  int get totalPixels => width * height;

  List<int> get rawPixels => List<int>.unmodifiable(_pixels);

  bool isWithinBounds(int x, int y) {
    return x >= 0 && x < width && y >= 0 && y < height;
  }

  int _index(int x, int y) => y * width + x;

  Color getPixel(int x, int y) {
    if (!isWithinBounds(x, y)) return Colors.transparent;
    final value = _pixels[_index(x, y)];
    return Color(value);
  }

  int getPixelValue(int x, int y) {
    if (!isWithinBounds(x, y)) return 0;
    return _pixels[_index(x, y)];
  }

  /// Sets a pixel color. Returns true if the pixel value changed.
  bool setPixel(int x, int y, Color color) {
    if (!isWithinBounds(x, y)) return false;
    final idx = _index(x, y);
    final value = color.value;
    if (_pixels[idx] == value) return false;
    _pixels[idx] = value;
    return true;
  }

  /// Erases a pixel to transparent (0). Returns true if it was not already transparent.
  bool erasePixel(int x, int y) {
    if (!isWithinBounds(x, y)) return false;
    final idx = _index(x, y);
    if (_pixels[idx] == 0) return false;
    _pixels[idx] = 0;
    return true;
  }

  /// Flood fills contiguous pixels of matching color with targetColor.
  bool floodFill(int startX, int startY, Color targetColor) {
    if (!isWithinBounds(startX, startY)) return false;

    final targetVal = targetColor.value;
    final initialVal = _pixels[_index(startX, startY)];

    if (initialVal == targetVal) return false;

    bool changed = false;
    final queue = Queue<PointInt>();
    final visited = List<bool>.filled(width * height, false);

    queue.add(PointInt(startX, startY));
    visited[_index(startX, startY)] = true;

    while (queue.isNotEmpty) {
      final p = queue.removeFirst();
      final idx = _index(p.x, p.y);

      _pixels[idx] = targetVal;
      changed = true;

      // Check 4 adjacent neighbors (Up, Down, Left, Right)
      final neighbors = [
        PointInt(p.x + 1, p.y),
        PointInt(p.x - 1, p.y),
        PointInt(p.x, p.y + 1),
        PointInt(p.x, p.y - 1),
      ];

      for (final n in neighbors) {
        if (isWithinBounds(n.x, n.y)) {
          final nIdx = _index(n.x, n.y);
          if (!visited[nIdx] && _pixels[nIdx] == initialVal) {
            visited[nIdx] = true;
            queue.add(n);
          }
        }
      }
    }

    return changed;
  }

  void clear() {
    _pixels.fillRange(0, _pixels.length, 0);
  }

  PixelCanvasData clone() {
    return PixelCanvasData(
      width: width,
      height: height,
      initialPixels: List<int>.from(_pixels),
    );
  }

  List<int> toList() => List<int>.from(_pixels);

  bool hasContent() {
    for (final p in _pixels) {
      if (p != 0) return true;
    }
    return false;
  }
}

class PointInt {
  final int x;
  final int y;
  const PointInt(this.x, this.y);
}
