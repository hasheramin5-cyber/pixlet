import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/pixel_canvas_data.dart';

class ExportService {
  /// Generates a PNG byte stream at true resolution or nearest-neighbor upscale.
  /// Anti-aliasing is explicitly disabled to preserve razor-sharp pixel edges.
  static Future<Uint8List> renderPngBytes({
    required PixelCanvasData canvasData,
    required int scale,
    required bool transparentBackground,
    Color backgroundColor = Colors.white,
  }) async {
    final outWidth = canvasData.width * scale;
    final outHeight = canvasData.height * scale;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, outWidth.toDouble(), outHeight.toDouble()),
    );

    if (!transparentBackground) {
      final bgPaint = Paint()..color = backgroundColor;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, outWidth.toDouble(), outHeight.toDouble()),
        bgPaint,
      );
    }

    final pixelPaint = Paint()
      ..isAntiAlias = false
      ..style = PaintingStyle.fill;

    for (int y = 0; y < canvasData.height; y++) {
      for (int x = 0; x < canvasData.width; x++) {
        final color = canvasData.getPixel(x, y);
        if (color.alpha > 0) {
          pixelPaint.color = color;
          canvas.drawRect(
            Rect.fromLTWH(
              (x * scale).toDouble(),
              (y * scale).toDouble(),
              scale.toDouble(),
              scale.toDouble(),
            ),
            pixelPaint,
          );
        }
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(outWidth, outHeight);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Failed to encode image to PNG format');
    }

    return byteData.buffer.asUint8List();
  }

  /// Exports and triggers native platform share sheet.
  static Future<bool> shareArtwork({
    required Uint8List pngBytes,
    required String fileName,
    required String title,
    Rect? sharePositionOrigin,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final cleanName = fileName.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
      final finalName = cleanName.isEmpty ? 'pixlet_artwork' : cleanName;
      final file = File('${tempDir.path}/$finalName.png');

      await file.writeAsBytes(pngBytes, flush: true);

      final result = await Share.shareXFiles(
        [
          XFile(
            file.path,
            mimeType: 'image/png',
            name: '$finalName.png',
          )
        ],
        subject: title,
        text: 'Created with Pixlet — Pixel Art Studio',
        sharePositionOrigin: sharePositionOrigin,
      );

      return result.status == ShareResultStatus.success;
    } catch (e) {
      debugPrint('Export/Share error: $e');
      rethrow;
    }
  }
}
