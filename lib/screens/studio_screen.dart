import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/project_metadata.dart';
import '../state/canvas_state.dart';
import '../widgets/canvas_viewport.dart';
import '../widgets/tool_bar.dart';
import '../widgets/palette_bar.dart';
import '../widgets/export_dialog.dart';

class StudioScreen extends StatefulWidget {
  final ProjectMetadata project;

  const StudioScreen({
    super.key,
    required this.project,
  });

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  late CanvasState _state;

  @override
  void initState() {
    super.initState();
    _state = CanvasState(initialProject: widget.project);
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    await _state.saveCurrentProject();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text('"${_state.currentProject.name}" saved locally!'),
            ],
          ),
          backgroundColor: const Color(0xFF2B2D42),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _confirmClearCanvas() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFCFAF6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE8E4DA)),
        ),
        title: const Text(
          'Clear Canvas?',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF2B2D42),
          ),
        ),
        content: const Text(
          'This will erase all pixels on the current canvas. You can still undo this action.',
          style: TextStyle(color: Color(0xFF4A4E69), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8D99AE))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF004D),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _state.clearCanvas();
    }
  }

  void _showRenameDialog() {
    final controller = TextEditingController(text: _state.currentProject.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFCFAF6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE8E4DA)),
        ),
        title: const Text(
          'Rename Artwork',
          style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2B2D42)),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE4DFD5)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8D99AE))),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                _state.renameCurrentProject(newName);
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B2D42),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save Name'),
          ),
        ],
      ),
    );
  }

  void _openExportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => ExportDialog(
        canvasData: _state.canvasData,
        projectName: _state.currentProject.name,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_state.isDirty) {
      await _state.saveCurrentProject();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) {
        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop && _state.isDirty) {
              await _state.saveCurrentProject();
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF6F4EF),
            appBar: AppBar(
              backgroundColor: const Color(0xFFFCFAF6),
              elevation: 0,
              scrolledUnderElevation: 1,
              titleSpacing: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                color: const Color(0xFF2B2D42),
                tooltip: 'Back to Gallery',
                onPressed: () async {
                  if (_state.isDirty) {
                    await _state.saveCurrentProject();
                  }
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              title: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _showRenameDialog,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          _state.currentProject.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2B2D42),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit_rounded, size: 14, color: Color(0xFF8D99AE)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAE5DA),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${_state.canvasWidth}×${_state.canvasHeight}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4A4E69),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                // Clear Canvas
                IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded, size: 22),
                  tooltip: 'Clear Canvas',
                  color: const Color(0xFF4A4E69),
                  onPressed: _confirmClearCanvas,
                ),
                // Save Artwork
                IconButton(
                  icon: Icon(
                    _state.isDirty ? Icons.save_rounded : Icons.check_circle_outline_rounded,
                    size: 22,
                  ),
                  tooltip: _state.isDirty ? 'Save Changes' : 'Saved',
                  color: _state.isDirty ? const Color(0xFFFF004D) : const Color(0xFF4A4E69),
                  onPressed: _handleSave,
                ),
                // Export / Share
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: IconButton(
                    icon: const Icon(Icons.ios_share_rounded, size: 22),
                    tooltip: 'Export & Share',
                    color: const Color(0xFF2B2D42),
                    onPressed: _openExportDialog,
                  ),
                ),
              ],
            ),
            body: Stack(
              children: [
                // Canvas Center Area
                Positioned.fill(
                  child: CanvasViewport(state: _state),
                ),

                // Bottom Controls Overlay
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 16,
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Palette Swatches Strip
                        PaletteBar(state: _state),
                        const SizedBox(height: 10),

                        // Tool Selection Bar
                        ToolBar(state: _state),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
