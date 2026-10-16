import 'package:flutter/material.dart';
import '../models/tool_type.dart';
import '../state/canvas_state.dart';

class ToolBar extends StatelessWidget {
  final CanvasState state;

  const ToolBar({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE8E4DA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Undo
          _ActionToolButton(
            icon: Icons.undo_rounded,
            tooltip: 'Undo (Ctrl+Z)',
            isEnabled: state.canUndo,
            onTap: state.undo,
          ),

          // Redo
          _ActionToolButton(
            icon: Icons.redo_rounded,
            tooltip: 'Redo (Ctrl+Y)',
            isEnabled: state.canRedo,
            onTap: state.redo,
          ),

          const SizedBox(width: 4),
          Container(
            height: 24,
            width: 1,
            color: const Color(0xFFE6E2D8),
            margin: const EdgeInsets.symmetric(horizontal: 4),
          ),
          const SizedBox(width: 4),

          // Drawing tools
          for (final tool in ToolType.values)
            _SelectableToolButton(
              tool: tool,
              isSelected: state.currentTool == tool,
              onTap: () => state.setTool(tool),
            ),
        ],
      ),
    );
  }
}

class _SelectableToolButton extends StatelessWidget {
  final ToolType tool;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableToolButton({
    required this.tool,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${tool.label}: ${tool.tooltip}',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2B2D42) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: Icon(
                  tool.icon,
                  size: 20,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF4A4E69),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionToolButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isEnabled;
  final VoidCallback onTap;

  const _ActionToolButton({
    required this.icon,
    required this.tooltip,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isEnabled ? onTap : null,
            child: SizedBox(
              width: 40,
              height: 44,
              child: Icon(
                icon,
                size: 20,
                color: isEnabled
                    ? const Color(0xFF2B2D42)
                    : const Color(0xFFCDC8BD),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
