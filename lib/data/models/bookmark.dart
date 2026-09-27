class Bookmark {
  final String id;
  final String bookId;
  final int page;
  final double position;
  final String title;
  final DateTime createdAt;

  const Bookmark({
    required this.id,
    required this.bookId,
    required this.page,
    this.position = 0.0,
    required this.title,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'page': page,
      'position': position,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      page: json['page'] as int,
      position: (json['position'] as num?)?.toDouble() ?? 0.0,
      title: json['title'] as String? ?? 'Página ${json['page']}',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
