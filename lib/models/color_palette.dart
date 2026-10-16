import 'package:flutter/material.dart';

class PaletteCollection {
  final String name;
  final String description;
  final List<Color> colors;

  const PaletteCollection({
    required this.name,
    required this.description,
    required this.colors,
  });
}

class PredefinedPalettes {
  static const PaletteCollection pico8 = PaletteCollection(
    name: 'PICO-8 Classics',
    description: 'Iconic 16-color retro video game palette',
    colors: [
      Color(0xFF000000), // Black
      Color(0xFF1D2B53), // Dark Blue
      Color(0xFF7E2553), // Dark Purple
      Color(0xFF008751), // Dark Green
      Color(0xFFAB5236), // Brown
      Color(0xFF5F574F), // Dark Gray
      Color(0xFFC2C3C7), // Light Gray
      Color(0xFFFFF1E8), // White
      Color(0xFFFF004D), // Red
      Color(0xFFFFA300), // Orange
      Color(0xFFFFEC27), // Yellow
      Color(0xFF00E436), // Green
      Color(0xFF29ADFF), // Blue
      Color(0xFF83769C), // Indigo
      Color(0xFFFF77A8), // Pink
      Color(0xFFFFCCAA), // Peach
    ],
  );

  static const PaletteCollection gameBoy = PaletteCollection(
    name: 'GameBoy DMG',
    description: 'Nostalgic 4-shade greenish monochrome palette',
    colors: [
      Color(0xFF0F380F), // Darkest green
      Color(0xFF306230), // Dark green
      Color(0xFF8BAC0F), // Light green
      Color(0xFF9BBC0F), // Lightest yellowish green
    ],
  );

  static const PaletteCollection cyberpunk = PaletteCollection(
    name: 'Cyberpunk Neon',
    description: 'High-contrast synthetic glow & deep night tones',
    colors: [
      Color(0xFF0A0915),
      Color(0xFF18153A),
      Color(0xFF2E2B6D),
      Color(0xFF00F0FF), // Neon cyan
      Color(0xFF05FFA1), // Neon mint
      Color(0xFFFF0055), // Neon magenta
      Color(0xFFFFE600), // Neon yellow
      Color(0xFFB026FF), // Neon purple
      Color(0xFFFFFFFF),
    ],
  );

  static const PaletteCollection pastelBloom = PaletteCollection(
    name: 'Pastel Studio',
    description: 'Gentle, modern aesthetic pastels for subtle craft',
    colors: [
      Color(0xFF2B2D42),
      Color(0xFF8D99AE),
      Color(0xFFEDF2F4),
      Color(0xFFEF233C),
      Color(0xFFD90429),
      Color(0xFFFFB5A7),
      Color(0xFFFCD5CE),
      Color(0xFFF8EDEB),
      Color(0xFFF9DCC4),
      Color(0xFFFEC89A),
      Color(0xFFB7E4C7),
      Color(0xFF95D5B2),
      Color(0xFF74C69D),
      Color(0xFFBEE1E6),
      Color(0xFFCDDAFD),
    ],
  );

  static const PaletteCollection earthWarmth = PaletteCollection(
    name: 'Earth & Clay',
    description: 'Terracotta, ochre, olive, and deep walnut',
    colors: [
      Color(0xFF231B15),
      Color(0xFF4A3728),
      Color(0xFF8C5835),
      Color(0xFFC77D48),
      Color(0xFFDFA168),
      Color(0xFFE8C8A3),
      Color(0xFF3B4731),
      Color(0xFF5E6F43),
      Color(0xFF90A955),
      Color(0xFF31572C),
      Color(0xFFC44536),
      Color(0xFFF4F1DE),
    ],
  );

  static const List<PaletteCollection> all = [
    pico8,
    pastelBloom,
    earthWarmth,
    cyberpunk,
    gameBoy,
  ];
}
