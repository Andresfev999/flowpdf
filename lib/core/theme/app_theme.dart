import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppPalette {
  final String id;
  final String name;
  final Color primary;
  final Color accent;
  final String description;

  const AppPalette({
    required this.id,
    required this.name,
    required this.primary,
    required this.accent,
    required this.description,
  });
}

class AppTheme {
  // Paletas de Colores Configurables (6 Paletas)
  static const List<AppPalette> palettes = [
    AppPalette(
      id: 'indigo',
      name: 'Índigo Flow',
      primary: Color(0xFF6C63FF),
      accent: Color(0xFF8B85FF),
      description: 'Elegante, equilibrado y el color oficial de FlowPDF',
    ),
    AppPalette(
      id: 'emerald',
      name: 'Menta Esmeralda',
      primary: Color(0xFF059669),
      accent: Color(0xFF34D399),
      description: 'Fresco, relajante y cómodo para largas lecturas',
    ),
    AppPalette(
      id: 'ocean',
      name: 'Azul Océano',
      primary: Color(0xFF0284C7),
      accent: Color(0xFF38BDF8),
      description: 'Sereno, profundo y con enfoque profesional',
    ),
    AppPalette(
      id: 'amber',
      name: 'Ámbar & Sepia',
      primary: Color(0xFFD97706),
      accent: Color(0xFFFBBF24),
      description: 'Cálido, tradicional y evocador de libros clásicos',
    ),
    AppPalette(
      id: 'crimson',
      name: 'Rosa Carmín',
      primary: Color(0xFFE11D48),
      accent: Color(0xFFFB7185),
      description: 'Vibrante, inspirador y de alto impacto visual',
    ),
    AppPalette(
      id: 'copper',
      name: 'Cobre & Carbón',
      primary: Color(0xFFEA580C),
      accent: Color(0xFFFB923C),
      description: 'Moderno, enérgico y con gran contraste en modo oscuro',
    ),
  ];

  static AppPalette getPalette(String id) {
    return palettes.firstWhere(
      (p) => p.id == id,
      orElse: () => palettes[0],
    );
  }

  // Constantes de compatibilidad
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color lightBackground = Color(0xFFF7F7F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF18181B);
  static const Color secondaryText = Color(0xFF71717A);

  static const Color darkBackground = Color(0xFF101014);
  static const Color darkSurface = Color(0xFF18181B);
  static const Color darkText = Color(0xFFF4F4F5);

  // Reader Themes
  static const ReaderTheme lightReader = ReaderTheme(
    id: 'light',
    name: 'Claro',
    backgroundColor: Color(0xFFFAFAFA),
    textColor: Color(0xFF18181B),
    secondaryColor: Color(0xFF71717A),
    appBarColor: Color(0xFFF0F0F2),
  );

  static const ReaderTheme paperReader = ReaderTheme(
    id: 'paper',
    name: 'Papel',
    backgroundColor: Color(0xFFF5EFEB),
    textColor: Color(0xFF3E2723),
    secondaryColor: Color(0xFF795548),
    appBarColor: Color(0xFFEBE3DD),
  );

  static const ReaderTheme darkReader = ReaderTheme(
    id: 'dark',
    name: 'Oscuro',
    backgroundColor: Color(0xFF18181B),
    textColor: Color(0xFFE4E4E7),
    secondaryColor: Color(0xFFA1A1AA),
    appBarColor: Color(0xFF27272A),
  );

  static const ReaderTheme amoledReader = ReaderTheme(
    id: 'amoled',
    name: 'AMOLED',
    backgroundColor: Color(0xFF000000),
    textColor: Color(0xFFD4D4D8),
    secondaryColor: Color(0xFF71717A),
    appBarColor: Color(0xFF121212),
  );

  static ReaderTheme getReaderTheme(String id) {
    switch (id) {
      case 'paper':
        return paperReader;
      case 'dark':
        return darkReader;
      case 'amoled':
        return amoledReader;
      case 'light':
      default:
        return lightReader;
    }
  }

  static ThemeData getLightTheme([String paletteId = 'indigo']) {
    final palette = getPalette(paletteId);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: palette.primary,
      colorScheme: ColorScheme.light(
        primary: palette.primary,
        secondary: palette.accent,
        surface: lightSurface,
        onSurface: lightText,
      ),
      scaffoldBackgroundColor: lightBackground,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightText,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: lightText,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: palette.primary.withOpacity(0.18),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: palette.primary);
          }
          return const IconThemeData(color: secondaryText);
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData getDarkTheme([String paletteId = 'indigo']) {
    final palette = getPalette(paletteId);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: palette.primary,
      colorScheme: ColorScheme.dark(
        primary: palette.primary,
        secondary: palette.accent,
        surface: darkSurface,
        onSurface: darkText,
      ),
      scaffoldBackgroundColor: darkBackground,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkText,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: palette.primary.withOpacity(0.25),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: palette.accent);
          }
          return const IconThemeData(color: secondaryText);
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData get lightTheme => getLightTheme('indigo');
  static ThemeData get darkTheme => getDarkTheme('indigo');
}

class ReaderTheme {
  final String id;
  final String name;
  final Color backgroundColor;
  final Color textColor;
  final Color secondaryColor;
  final Color appBarColor;

  const ReaderTheme({
    required this.id,
    required this.name,
    required this.backgroundColor,
    required this.textColor,
    required this.secondaryColor,
    required this.appBarColor,
  });
}
