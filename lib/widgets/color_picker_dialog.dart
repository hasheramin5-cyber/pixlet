import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;

  const ColorPickerDialog({
    super.key,
    required this.initialColor,
  });

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late HSVColor _hsvColor;
  late TextEditingController _hexController;

  @override
  void initState() {
    super.initState();
    _hsvColor = HSVColor.fromColor(widget.initialColor);
    _hexController = TextEditingController(text: _colorToHex(widget.initialColor));
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  void _onHexSubmitted(String val) {
    String clean = val.replaceAll('#', '').trim();
    if (clean.length == 6) {
      final parsed = int.tryParse('FF$clean', radix: 16);
      if (parsed != null) {
        setState(() {
          _hsvColor = HSVColor.fromColor(Color(parsed));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _hsvColor.toColor();

    return Dialog(
      backgroundColor: const Color(0xFFFCFAF6),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFE8E4DA)),
      ),
      child: Container(
        width: 340,
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
                  'Color Studio',
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
            const SizedBox(height: 18),

            // Color Preview & Comparison
            Row(
              children: [
                // Original color
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ORIGINAL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF8D99AE),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: widget.initialColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE6E2D8)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF8D99AE)),
                const SizedBox(width: 12),
                // New Color
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NEW',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF8D99AE),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: currentColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2B2D42), width: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Hue Slider
            _buildSliderLabel('HUE', '${_hsvColor.hue.round()}°'),
            Container(
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF0000),
                    Color(0xFFFFFF00),
                    Color(0xFF00FF00),
                    Color(0xFF00FFFF),
                    Color(0xFF0000FF),
                    Color(0xFFFF00FF),
                    Color(0xFFFF0000),
                  ],
                ),
              ),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 0,
                  thumbColor: Colors.white,
                  overlayShape: SliderComponentShape.noOverlay,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                ),
                child: Slider(
                  value: _hsvColor.hue,
                  min: 0,
                  max: 360,
                  onChanged: (val) {
                    setState(() {
                      _hsvColor = _hsvColor.withHue(val);
                      _hexController.text = _colorToHex(_hsvColor.toColor());
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Saturation Slider
            _buildSliderLabel('SATURATION', '${(_hsvColor.saturation * 100).round()}%'),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF2B2D42),
                inactiveTrackColor: const Color(0xFFE4DFD5),
                thumbColor: const Color(0xFF2B2D42),
                overlayShape: SliderComponentShape.noOverlay,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: _hsvColor.saturation,
                min: 0,
                max: 1.0,
                onChanged: (val) {
                  setState(() {
                    _hsvColor = _hsvColor.withSaturation(val);
                    _hexController.text = _colorToHex(_hsvColor.toColor());
                  });
                },
              ),
            ),
            const SizedBox(height: 10),

            // Brightness / Value Slider
            _buildSliderLabel('BRIGHTNESS', '${(_hsvColor.value * 100).round()}%'),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF2B2D42),
                inactiveTrackColor: const Color(0xFFE4DFD5),
                thumbColor: const Color(0xFF2B2D42),
                overlayShape: SliderComponentShape.noOverlay,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: _hsvColor.value,
                min: 0,
                max: 1.0,
                onChanged: (val) {
                  setState(() {
                    _hsvColor = _hsvColor.withValue(val);
                    _hexController.text = _colorToHex(_hsvColor.toColor());
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Hex Input Field
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE4DFD5)),
                    ),
                    child: TextField(
                      controller: _hexController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 11),
                        hintText: '#RRGGBB',
                      ),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF2B2D42),
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(7),
                      ],
                      onSubmitted: _onHexSubmitted,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).pop(currentColor);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B2D42),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Select',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderLabel(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8D99AE),
              letterSpacing: 0.5,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2B2D42),
            ),
          ),
        ],
      ),
    );
  }
}
