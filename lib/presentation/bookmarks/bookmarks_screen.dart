import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/book.dart';
import '../../data/models/bookmark.dart';
import '../../data/repositories/book_repository.dart';
import '../reader/reader_screen.dart';

class BookmarksScreen extends StatelessWidget {
  final BookRepository bookRepository;

  const BookmarksScreen({super.key, required this.bookRepository});

  void _openReaderAtPage(BuildContext context, Book book, int page) {
    bookRepository.updateProgress(book.id, page);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReaderScreen(
          book: book.copyWith(currentPage: page),
          bookRepository: bookRepository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: bookRepository,
      builder: (context, _) {
        final bookmarks = bookRepository.bookmarks;
        final books = bookRepository.books;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Marcadores',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
          body: bookmarks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.bookmark_border_rounded, size: 48, color: AppTheme.primaryColor),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aún no tienes páginas marcadas',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Toca el ícono 🔖 mientras lees para guardar tus páginas favoritas.',
                        style: GoogleFonts.inter(fontSize: 13, color: AppTheme.secondaryText),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    final bookBookmarks = bookmarks.where((bm) => bm.bookId == book.id).toList();

                    if (bookBookmarks.isEmpty) return const SizedBox.shrink();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      color: Theme.of(context).cardColor,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.menu_book, size: 18, color: AppTheme.primaryColor),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    book.title,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            ...bookBookmarks.map((bm) => _buildBookmarkItem(context, book, bm)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildBookmarkItem(BuildContext context, Book book, Bookmark bookmark) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.bookmark, color: AppTheme.primaryColor, size: 22),
      title: Text(
        'Página ${bookmark.page}',
        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        bookmark.title,
        style: const TextStyle(fontSize: 12, color: AppTheme.secondaryText),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.secondaryText),
        onPressed: () => bookRepository.removeBookmark(bookmark.id),
      ),
      onTap: () => _openReaderAtPage(context, book, bookmark.page),
    );
  }
}
