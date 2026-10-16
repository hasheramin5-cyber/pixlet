import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/gallery_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure system UI overlays for warm light design
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFFCFAF6),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const PixletApp());
}

class PixletApp extends StatelessWidget {
  const PixletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixlet — Pixel Art Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F5F0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2B2D42),
          surface: const Color(0xFFFCFAF6),
          brightness: Brightness.light,
          primary: const Color(0xFF2B2D42),
          secondary: const Color(0xFFFF004D),
        ),
        dividerColor: const Color(0xFFE8E4DA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFCFAF6),
          foregroundColor: Color(0xFF2B2D42),
          elevation: 0,
          scrolledUnderElevation: 1,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: const Color(0xFF2B2D42),
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          waitDuration: const Duration(milliseconds: 400),
        ),
      ),
      home: const GalleryScreen(),
    );
  }
}
