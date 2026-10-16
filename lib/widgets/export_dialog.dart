import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/pixel_canvas_data.dart';
import '../painters/thumbnail_painter.dart';
import '../services/export_service.dart';

class ExportDialog extends StatefulWidget {
  final PixelCanvasData canvasData;
  final String projectName;

  const ExportDialog({
    super.key,
    required this.canvasData,
    required this.projectName,
  });

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  int _selectedScale = 16;
  bool _transparentBackground = true;
  Color _backgroundColor = Colors.white;
  bool _isExporting = false;
  String? _statusMessage;

  final List<int> _scaleOptions = [1, 8, 16, 32];

  int get _exportWidth => widget.canvasData.width * _selectedScale;
  int get _exportHeight => widget.canvasData.height * _selectedScale;

  Future<void> _handleExportAndShare() async {
    setState(() {
      _isExporting = true;
      _statusMessage = 'Rendering crisp PNG...';
    });

    try {
      final pngBytes = await ExportService.renderPngBytes(
        canvasData: widget.canvasData,
        scale: _selectedScale,
        transparentBackground: _transparentBackground,
        backgroundColor: _backgroundColor,
      );

      setState(() {
        _statusMessage = 'Opening share sheet...';
      });

      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;

      await ExportService.shareArtwork(
        pngBytes: pngBytes,
        fileName: widget.projectName,
        title: '${widget.projectName} (${_exportWidth}x$_exportHeight)',
        sharePositionOrigin: origin,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isExporting = false;
          _statusMessage = 'Export failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFCFAF6),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFE8E4DA)),
      ),
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Export Pixel Art',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2B2D42),
                    letterSpacing: -0.2,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: const Color(0xFF8D99AE),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Artwork Preview
            Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE4DFD5)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0C000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: CustomPaint(
                  painter: ThumbnailPainter(
                    pixels: widget.canvasData.toList(),
                    gridWidth: widget.canvasData.width,
                    gridHeight: widget.canvasData.height,
                    drawCheckerboard: _transparentBackground,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Scale Options
            const Text(
              'RESOLUTION SCALE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8D99AE),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: _scaleOptions.map((s) {
                final isSelected = _selectedScale == s;
                final label = s == 1 ? '1x (Raw)' : '${s}x';
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => setState(() => _selectedScale = s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF2B2D42) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF2B2D42)
                                : const Color(0xFFE4DFD5),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : const Color(0xFF4A4E69),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Dimension Summary Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF2EFE8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Output Dimensions',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A4E69),
                    ),
                  ),
                  Text(
                    '${_exportWidth} × ${_exportHeight} px',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2B2D42),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Transparent Background Toggle
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() => _transparentBackground = !_transparentBackground),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Icon(
                      _transparentBackground
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      color: _transparentBackground
                          ? const Color(0xFFFF004D)
                          : const Color(0xFF8D99AE),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Transparent Background',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2B2D42),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_statusMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _statusMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: _statusMessage!.contains('failed')
                      ? Colors.red
                      : const Color(0xFF8D99AE),
                ),
              ),
            ],
            const SizedBox(height: 18),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isExporting ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4A4E69),
                      side: const BorderSide(color: Color(0xFFE4DFD5)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    icon: _isExporting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.share_rounded, size: 18),
                    label: Text(_isExporting ? 'Exporting...' : 'Export & Share'),
                    onPressed: _isExporting ? null : _handleExportAndShare,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B2D42),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
