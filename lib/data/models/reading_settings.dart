class ReadingSettings {
  final String id;
  final String bookId;
  final String fontFamily; // 'Literata', 'Inter', 'Merriweather', 'Lora'
  final double fontSize;   // 12.0 - 28.0
  final double lineHeight; // 1.2 - 2.2
  final double margin;     // 8.0 - 32.0
  final String theme;      // 'light', 'paper', 'dark', 'amoled'
  final String readingMode; // 'flow', 'pdf'

  const ReadingSettings({
    required this.id,
    required this.bookId,
    this.fontFamily = 'Literata',
    this.fontSize = 17.0,
    this.lineHeight = 1.6,
    this.margin = 18.0,
    this.theme = 'paper',
    this.readingMode = 'flow',
  });

  ReadingSettings copyWith({
    String? id,
    String? bookId,
    String? fontFamily,
    double? fontSize,
    double? lineHeight,
    double? margin,
    String? theme,
    String? readingMode,
  }) {
    return ReadingSettings(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      margin: margin ?? this.margin,
      theme: theme ?? this.theme,
      readingMode: readingMode ?? this.readingMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'lineHeight': lineHeight,
      'margin': margin,
      'theme': theme,
      'readingMode': readingMode,
    };
  }

  factory ReadingSettings.fromJson(Map<String, dynamic> json) {
    return ReadingSettings(
      id: json['id'] as String? ?? 'default',
      bookId: json['bookId'] as String? ?? '',
      fontFamily: json['fontFamily'] as String? ?? 'Literata',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 17.0,
      lineHeight: (json['lineHeight'] as num?)?.toDouble() ?? 1.6,
      margin: (json['margin'] as num?)?.toDouble() ?? 18.0,
      theme: json['theme'] as String? ?? 'paper',
      readingMode: json['readingMode'] as String? ?? 'flow',
    );
  }

  factory ReadingSettings.defaultSettings(String bookId) {
    return ReadingSettings(
      id: 'settings_$bookId',
      bookId: bookId,
      fontFamily: 'Literata',
      fontSize: 17.0,
      lineHeight: 1.6,
      margin: 18.0,
      theme: 'paper',
      readingMode: 'flow',
    );
  }
}
