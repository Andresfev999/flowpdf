import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/book.dart';
import '../../data/repositories/book_repository.dart';
import '../home/widgets/import_pdf_dialog.dart';
import '../reader/reader_screen.dart';

class LibraryScreen extends StatefulWidget {
  final BookRepository bookRepository;

  const LibraryScreen({super.key, required this.bookRepository});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _selectedFilter = 'Todos'; // 'Todos', 'Recientes', 'En progreso', 'Terminados'
  String _searchQuery = '';
  bool _isSearching = false;

  List<Book> _filterBooks(List<Book> books) {
    var filtered = List<Book>.from(books);

    // Búsqueda por texto
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where((b) => b.title.toLowerCase().contains(q) || b.author.toLowerCase().contains(q))
          .toList();
    }

    // Filtros de categoría
    switch (_selectedFilter) {
      case 'Recientes':
        filtered.sort((a, b) => b.lastReadAt.compareTo(a.lastReadAt));
        break;
      case 'En progreso':
        filtered = filtered.where((b) => b.progress > 0 && b.progress < 0.98).toList();
        break;
      case 'Terminados':
        filtered = filtered.where((b) => b.progress >= 0.98).toList();
        break;
      case 'Todos':
      default:
        final sortBy = widget.bookRepository.appSettings.librarySortBy;
        if (sortBy == 'title') {
          filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        } else if (sortBy == 'progress') {
          filtered.sort((a, b) => b.progress.compareTo(a.progress));
        } else if (sortBy == 'dateAdded') {
          filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        } else {
          filtered.sort((a, b) => b.lastReadAt.compareTo(a.lastReadAt));
        }
        break;
    }

    return filtered;
  }

  void _openReader(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReaderScreen(
          book: book,
          bookRepository: widget.bookRepository,
        ),
      ),
    );
  }

  void _showBookActionsModal(Book book) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    book.title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.play_arrow_rounded, color: AppTheme.primaryColor),
                  title: const Text('Continuar leyendo'),
                  subtitle: Text('Página ${book.currentPage} de ${book.totalPages} (${book.progressPercent}%)'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openReader(book);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppTheme.secondaryText),
                  title: const Text('Información del libro'),
                  subtitle: Text('${book.totalPages} páginas • ${book.author}'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showBookInfoDialog(book);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  title: const Text('Eliminar de la biblioteca', style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmDelete(book);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBookInfoDialog(Book book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(book.title, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Autor: ${book.author}'),
            const SizedBox(height: 6),
            Text('Total de páginas: ${book.totalPages}'),
            const SizedBox(height: 6),
            Text('Progreso: ${book.progressPercent}%'),
            const SizedBox(height: 6),
            Text('Última lectura: ${DateFormat('dd/MM/yyyy HH:mm').format(book.lastReadAt)}'),
            const SizedBox(height: 6),
            Text('Ruta local: ${book.filePath}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  void _confirmDelete(Book book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar libro?'),
        content: Text('Se eliminará "${book.title}" y todos sus marcadores y progreso.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              widget.bookRepository.deleteBook(book.id);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.bookRepository,
      builder: (context, _) {
        final books = _filterBooks(widget.bookRepository.books);

        return Scaffold(
          appBar: AppBar(
            title: _isSearching
                ? TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Buscar libros o autores...',
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  )
                : Text('Biblioteca', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) _searchQuery = '';
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.add, color: AppTheme.primaryColor),
                tooltip: 'Importar PDF',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ImportPdfDialog(bookRepository: widget.bookRepository),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              // Barra de filtros horizontales: [Todos] [Recientes] [En progreso] [Terminados]
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip('Todos'),
                      _buildFilterChip('Recientes'),
                      _buildFilterChip('En progreso'),
                      _buildFilterChip('Terminados'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Lista vertical de libros
              Expanded(
                child: books.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isNotEmpty
                              ? 'No se encontraron libros con "$_searchQuery"'
                              : 'No hay libros en esta categoría',
                          style: const TextStyle(color: AppTheme.secondaryText),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: books.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final book = books[index];
                          return _buildBookRow(book);
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => ImportPdfDialog(bookRepository: widget.bookRepository),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {
          setState(() {
            _selectedFilter = label;
          });
        },
        selectedColor: AppTheme.primaryColor.withOpacity(0.18),
        checkmarkColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : AppTheme.secondaryText,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.grey.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildBookRow(Book book) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _openReader(book),
      onLongPress: () => _showBookActionsModal(book),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Portada
            Container(
              width: 58,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 4,
                    offset: const Offset(1, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: (book.coverPath != null && File(book.coverPath!).existsSync())
                    ? Image.file(
                        File(book.coverPath!),
                        width: 58,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF4A44B5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'PDF',
                              style: TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              book.title,
                              style: GoogleFonts.literata(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),

            // Título, autor, barra de progreso y fecha
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    book.author,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.secondaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Barra de progreso
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: book.progress,
                            minHeight: 4,
                            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${book.progressPercent}%',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  Text(
                    'Última lectura: ${DateFormat('dd MMM').format(book.lastReadAt)} • Pág. ${book.currentPage}/${book.totalPages}',
                    style: const TextStyle(fontSize: 10, color: AppTheme.secondaryText),
                  ),
                ],
              ),
            ),

            IconButton(
              icon: const Icon(Icons.more_vert, color: AppTheme.secondaryText),
              onPressed: () => _showBookActionsModal(book),
            ),
          ],
        ),
      ),
    );
  }
}
