import 'package:flutter/material.dart';

enum ToolType {
  pencil(
    label: 'Pencil',
    icon: Icons.edit_rounded,
    tooltip: 'Draw pixels (Tap or Drag)',
  ),
  eraser(
    label: 'Eraser',
    icon: Icons.auto_fix_high_rounded,
    tooltip: 'Erase pixels to transparent',
  ),
  bucket(
    label: 'Fill',
    icon: Icons.format_color_fill_rounded,
    tooltip: 'Flood fill contiguous area',
  ),
  eyedropper(
    label: 'Eyedropper',
    icon: Icons.colorize_rounded,
    tooltip: 'Sample color from canvas',
  ),
  pan(
    label: 'Pan & Zoom',
    icon: Icons.pan_tool_rounded,
    tooltip: 'Move and scale canvas',
  );

  final String label;
  final IconData icon;
  final String tooltip;

  const ToolType({
    required this.label,
    required this.icon,
    required this.tooltip,
  });
}
