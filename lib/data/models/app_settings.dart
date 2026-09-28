import 'package:flutter/material.dart';

class AppSettings {
  final String themeMode; // 'system', 'light', 'dark'
  final String colorPalette; // 'indigo', 'emerald', 'ocean', 'amber', 'crimson', 'copper'
  final String preferredFontFamily; // 'Literata', 'Inter', 'Merriweather', 'Lora'
  final double defaultFontSize; // 13.0 - 26.0
  final String defaultReadingTheme; // 'paper', 'light', 'dark', 'amoled'
  final String defaultReadingMode; // 'flow', 'pdf'
  final bool smoothPageTurn; // true: animada, false: instantánea
  final bool keepScreenOn; // mantener pantalla activa en lectura
  final String librarySortBy; // 'recent', 'title', 'progress', 'dateAdded'
  final String libraryViewMode; // 'list', 'grid'

  const AppSettings({
    this.themeMode = 'system',
    this.colorPalette = 'indigo',
    this.preferredFontFamily = 'Literata',
    this.defaultFontSize = 17.0,
    this.defaultReadingTheme = 'paper',
    this.defaultReadingMode = 'flow',
    this.smoothPageTurn = true,
    this.keepScreenOn = false,
    this.librarySortBy = 'recent',
    this.libraryViewMode = 'list',
  });

  ThemeMode get themeModeEnum {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  AppSettings copyWith({
    String? themeMode,
    String? colorPalette,
    String? preferredFontFamily,
    double? defaultFontSize,
    String? defaultReadingTheme,
    String? defaultReadingMode,
    bool? smoothPageTurn,
    bool? keepScreenOn,
    String? librarySortBy,
    String? libraryViewMode,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      colorPalette: colorPalette ?? this.colorPalette,
      preferredFontFamily: preferredFontFamily ?? this.preferredFontFamily,
      defaultFontSize: defaultFontSize ?? this.defaultFontSize,
      defaultReadingTheme: defaultReadingTheme ?? this.defaultReadingTheme,
      defaultReadingMode: defaultReadingMode ?? this.defaultReadingMode,
      smoothPageTurn: smoothPageTurn ?? this.smoothPageTurn,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      librarySortBy: librarySortBy ?? this.librarySortBy,
      libraryViewMode: libraryViewMode ?? this.libraryViewMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode,
      'colorPalette': colorPalette,
      'preferredFontFamily': preferredFontFamily,
      'defaultFontSize': defaultFontSize,
      'defaultReadingTheme': defaultReadingTheme,
      'defaultReadingMode': defaultReadingMode,
      'smoothPageTurn': smoothPageTurn,
      'keepScreenOn': keepScreenOn,
      'librarySortBy': librarySortBy,
      'libraryViewMode': libraryViewMode,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: json['themeMode'] as String? ?? 'system',
      colorPalette: json['colorPalette'] as String? ?? 'indigo',
      preferredFontFamily: json['preferredFontFamily'] as String? ?? 'Literata',
      defaultFontSize: (json['defaultFontSize'] as num?)?.toDouble() ?? 17.0,
      defaultReadingTheme: json['defaultReadingTheme'] as String? ?? 'paper',
      defaultReadingMode: json['defaultReadingMode'] as String? ?? 'flow',
      smoothPageTurn: json['smoothPageTurn'] as bool? ?? true,
      keepScreenOn: json['keepScreenOn'] as bool? ?? false,
      librarySortBy: json['librarySortBy'] as String? ?? 'recent',
      libraryViewMode: json['libraryViewMode'] as String? ?? 'list',
    );
  }

  factory AppSettings.defaultSettings() {
    return const AppSettings();
  }
}
