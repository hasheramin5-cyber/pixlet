import 'package:flutter/material.dart';
import '../models/color_palette.dart';
import '../state/canvas_state.dart';
import 'color_picker_dialog.dart';

class PaletteBar extends StatelessWidget {
  final CanvasState state;

  const PaletteBar({
    super.key,
    required this.state,
  });

  void _openColorPicker(BuildContext context) async {
    final picked = await showDialog<Color>(
      context: context,
      builder: (ctx) => ColorPickerDialog(initialColor: state.selectedColor),
    );
    if (picked != null) {
      state.setColor(picked);
    }
  }

  void _showPaletteMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFCFAF6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Curated Palettes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2B2D42),
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.colorize_rounded, size: 16),
                        label: const Text('Custom Picker'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _openColorPicker(context);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ...PredefinedPalettes.all.map((p) {
                  final isSelected = state.activePalette.name == p.name;
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      state.setActivePalette(p);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFF0EBE1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF2B2D42) : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                    color: const Color(0xFF2B2D42),
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  p.description,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF8D99AE),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Mini palette preview swatches
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: p.colors.take(5).map((c) {
                              return Container(
                                width: 16,
                                height: 16,
                                margin: const EdgeInsets.only(left: 3),
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0x22000000)),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E4DA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Selected Color Circle
          Tooltip(
            message: 'Current Color (Tap for Custom Picker)',
            child: GestureDetector(
              onTap: () => _openColorPicker(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: state.selectedColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFFFFF), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: state.selectedColor.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                    const BoxShadow(
                      color: Color(0x20000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.colorize_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Palette Switcher Button
          Tooltip(
            message: 'Switch Palette: ${state.activePalette.name}',
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showPaletteMenu(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F1EA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.activePalette.name.split(' ').first,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2B2D42),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down_rounded, size: 16, color: Color(0xFF4A4E69)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Horizontal Palette Swatches Scroll
          Expanded(
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: state.activePalette.colors.length,
                separatorBuilder: (ctx, i) => const SizedBox(width: 6),
                itemBuilder: (ctx, i) {
                  final color = state.activePalette.colors[i];
                  final isCurrent = state.selectedColor.value == color.value;

                  return GestureDetector(
                    onTap: () => state.setColor(color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: isCurrent ? 32 : 28,
                      height: isCurrent ? 32 : 28,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCurrent
                              ? const Color(0xFF2B2D42)
                              : const Color(0x22000000),
                          width: isCurrent ? 2.5 : 1.0,
                        ),
                        boxShadow: isCurrent
                            ? const [
                                BoxShadow(
                                  color: Color(0x30000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
