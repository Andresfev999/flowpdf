import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6C63FF);
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

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
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
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: primaryColor,
        unselectedItemColor: secondaryText,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
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
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryColor,
        unselectedItemColor: secondaryText,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
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
