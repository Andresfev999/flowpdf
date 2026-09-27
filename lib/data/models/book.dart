class Book {
  final String id;
  final String title;
  final String author;
  final String filePath;
  final String? coverPath;
  final int totalPages;
  final int currentPage;
  final double progress; // 0.0 - 1.0
  final DateTime lastReadAt;
  final DateTime createdAt;
  final String? currentChapter;

  const Book({
    required this.id,
    required this.title,
    this.author = 'Autor desconocido',
    required this.filePath,
    this.coverPath,
    required this.totalPages,
    this.currentPage = 1,
    this.progress = 0.0,
    required this.lastReadAt,
    required this.createdAt,
    this.currentChapter,
  });

  int get estimatedMinutesRemaining {
    final remainingPages = totalPages - currentPage;
    if (remainingPages <= 0) return 0;
    // Asume 1.5 a 2 minutos por página estándar
    return (remainingPages * 1.8).round();
  }

  int get progressPercent => (progress * 100).round();

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? filePath,
    String? coverPath,
    int? totalPages,
    int? currentPage,
    double? progress,
    DateTime? lastReadAt,
    DateTime? createdAt,
    String? currentChapter,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      filePath: filePath ?? this.filePath,
      coverPath: coverPath ?? this.coverPath,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      progress: progress ?? this.progress,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      createdAt: createdAt ?? this.createdAt,
      currentChapter: currentChapter ?? this.currentChapter,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'filePath': filePath,
      'coverPath': coverPath,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'progress': progress,
      'lastReadAt': lastReadAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'currentChapter': currentChapter,
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String? ?? 'Autor desconocido',
      filePath: json['filePath'] as String,
      coverPath: json['coverPath'] as String?,
      totalPages: json['totalPages'] as int? ?? 1,
      currentPage: json['currentPage'] as int? ?? 1,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      lastReadAt: json['lastReadAt'] != null
          ? DateTime.parse(json['lastReadAt'] as String)
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      currentChapter: json['currentChapter'] as String?,
    );
  }
}
