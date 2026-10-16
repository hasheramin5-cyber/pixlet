import 'package:flutter/material.dart';
import '../painters/checkerboard_painter.dart';
import '../painters/pixel_canvas_painter.dart';
import '../models/tool_type.dart';
import '../state/canvas_state.dart';

class CanvasViewport extends StatefulWidget {
  final CanvasState state;

  const CanvasViewport({
    super.key,
    required this.state,
  });

  @override
  State<CanvasViewport> createState() => _CanvasViewportState();
}

class _CanvasViewportState extends State<CanvasViewport> {
  final TransformationController _transformController = TransformationController();
  final GlobalKey _canvasKey = GlobalKey();

  int _activePointers = 0;
  static const double _canvasBaseSize = 340.0;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
  }

  void _zoomIn() {
    final matrix = _transformController.value.clone();
    matrix.scale(1.3, 1.3);
    _transformController.value = matrix;
  }

  void _zoomOut() {
    final matrix = _transformController.value.clone();
    matrix.scale(1 / 1.3, 1 / 1.3);
    _transformController.value = matrix;
  }

  void _handlePointerDown(PointerDownEvent event) {
    setState(() => _activePointers++);

    // If pan tool is active or more than one finger is touching, do not draw
    if (widget.state.currentTool == ToolType.pan || _activePointers > 1) {
      return;
    }

    final point = _screenToPixel(event.position);
    if (point != null) {
      widget.state.handlePointerDown(point.dx.toInt(), point.dy.toInt());
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (widget.state.currentTool == ToolType.pan || _activePointers > 1) {
      return;
    }

    final point = _screenToPixel(event.position);
    if (point != null) {
      widget.state.handlePointerMove(point.dx.toInt(), point.dy.toInt());
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    setState(() => _activePointers = (_activePointers - 1).clamp(0, 10));
    widget.state.handlePointerUp();
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    setState(() => _activePointers = (_activePointers - 1).clamp(0, 10));
    widget.state.handlePointerUp();
  }

  /// Transforms global screen coordinate to (0..width-1, 0..height-1) pixel coordinates
  Offset? _screenToPixel(Offset screenOffset) {
    final renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final localOffset = renderBox.globalToLocal(screenOffset);
    final size = renderBox.size;

    if (localOffset.dx < 0 ||
        localOffset.dx >= size.width ||
        localOffset.dy < 0 ||
        localOffset.dy >= size.height) {
      return null;
    }

    final pixelX = (localOffset.dx / size.width * widget.state.canvasWidth).floor();
    final pixelY = (localOffset.dy / size.height * widget.state.canvasHeight).floor();

    return Offset(
      pixelX.toDouble().clamp(0, widget.state.canvasWidth - 1),
      pixelY.toDouble().clamp(0, widget.state.canvasHeight - 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPanMode = widget.state.currentTool == ToolType.pan;

    return Stack(
      children: [
        // Background desk surface
        Positioned.fill(
          child: Container(
            color: const Color(0xFFF6F4EF),
          ),
        ),

        // Interactive Canvas Surface
        Positioned.fill(
          child: Listener(
            onPointerDown: _handlePointerDown,
            onPointerMove: _handlePointerMove,
            onPointerUp: _handlePointerUp,
            onPointerCancel: _handlePointerCancel,
            child: InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.5,
              maxScale: 20.0,
              panEnabled: isPanMode || _activePointers >= 2,
              scaleEnabled: true,
              boundaryMargin: const EdgeInsets.all(180),
              child: Center(
                child: Container(
                  width: _canvasBaseSize,
                  height: _canvasBaseSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    key: _canvasKey,
                    fit: StackFit.expand,
                    children: [
                      // 1. Checkerboard for transparent areas
                      const CustomPaint(
                        painter: CheckerboardPainter(squareSize: 12),
                      ),

                      // 2. Pixels & Grid
                      CustomPaint(
                        painter: PixelCanvasPainter(
                          canvasData: widget.state.canvasData,
                          showGrid: widget.state.showGrid,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Floating Viewport Controls (Reset zoom, zoom in/out, grid toggle)
        Positioned(
          top: 14,
          right: 14,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xEBFFFFFF),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE8E4DA)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FloatingActionButton(
                  icon: Icons.restart_alt_rounded,
                  tooltip: 'Reset View / Center',
                  onTap: _resetZoom,
                ),
                _FloatingActionButton(
                  icon: Icons.remove_rounded,
                  tooltip: 'Zoom Out',
                  onTap: _zoomOut,
                ),
                _FloatingActionButton(
                  icon: Icons.add_rounded,
                  tooltip: 'Zoom In',
                  onTap: _zoomIn,
                ),
                Container(
                  height: 18,
                  width: 1,
                  color: const Color(0xFFE4DFD5),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                ),
                _FloatingActionButton(
                  icon: widget.state.showGrid
                      ? Icons.grid_on_rounded
                      : Icons.grid_off_rounded,
                  tooltip: widget.state.showGrid ? 'Hide Grid' : 'Show Grid',
                  isActive: widget.state.showGrid,
                  onTap: widget.state.toggleGrid,
                ),
              ],
            ),
          ),
        ),

        // Pan Mode Indicator Banner
        if (isPanMode)
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2B2D42),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.pan_tool_rounded, size: 14, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Pan & Zoom Mode',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _FloatingActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isActive;

  const _FloatingActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: Icon(
              icon,
              size: 18,
              color: isActive
                  ? const Color(0xFFFF004D)
                  : const Color(0xFF4A4E69),
            ),
          ),
        ),
      ),
    );
  }
}
