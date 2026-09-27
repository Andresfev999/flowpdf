class Note {
  final String id;
  final String bookId;
  final int page;
  final String selectedText;
  final String content;
  final DateTime createdAt;

  const Note({
    required this.id,
    required this.bookId,
    required this.page,
    required this.selectedText,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'page': page,
      'selectedText': selectedText,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      page: json['page'] as int,
      selectedText: json['selectedText'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
