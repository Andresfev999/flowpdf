import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/book.dart';
import '../models/bookmark.dart';
import '../models/note.dart';
import '../models/reading_settings.dart';
import '../services/pdf_service.dart';

class BookRepository extends ChangeNotifier {
  static const String _booksKey = 'flowpdf_books';
  static const String _bookmarksKey = 'flowpdf_bookmarks';
  static const String _notesKey = 'flowpdf_notes';
  static const String _settingsPrefix = 'flowpdf_settings_';
  static const String _appSettingsKey = 'flowpdf_app_settings';

  List<Book> _books = [];
  List<Bookmark> _bookmarks = [];
  List<Note> _notes = [];
  AppSettings _appSettings = AppSettings.defaultSettings();
  bool _isLoading = true;

  List<Book> get books => List.unmodifiable(_books);
  List<Bookmark> get bookmarks => List.unmodifiable(_bookmarks);
  List<Note> get notes => List.unmodifiable(_notes);
  AppSettings get appSettings => _appSettings;
  bool get isLoading => _isLoading;

  Book? get lastReadBook {
    if (_books.isEmpty) return null;
    final sorted = List<Book>.from(_books)
      ..sort((a, b) => b.lastReadAt.compareTo(a.lastReadAt));
    return sorted.first;
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Cargar ajustes globales
      final settingsJson = prefs.getString(_appSettingsKey);
      if (settingsJson != null) {
        try {
          _appSettings = AppSettings.fromJson(jsonDecode(settingsJson));
        } catch (e) {
          debugPrint('Error parseando AppSettings: $e');
        }
      }

      // Cargar libros
      final booksJson = prefs.getString(_booksKey);
      if (booksJson != null) {
        final List<dynamic> decoded = jsonDecode(booksJson);
        _books = decoded.map((item) => Book.fromJson(item as Map<String, dynamic>)).toList();
      }

      // Cargar marcadores
      final bookmarksJson = prefs.getString(_bookmarksKey);
      if (bookmarksJson != null) {
        final List<dynamic> decoded = jsonDecode(bookmarksJson);
        _bookmarks = decoded.map((item) => Bookmark.fromJson(item as Map<String, dynamic>)).toList();
      }

      // Cargar notas
      final notesJson = prefs.getString(_notesKey);
      if (notesJson != null) {
        final List<dynamic> decoded = jsonDecode(notesJson);
        _notes = decoded.map((item) => Note.fromJson(item as Map<String, dynamic>)).toList();
      }

      // Generar portadas para libros existentes que aún no la tengan
      _checkAndGenerateMissingCovers();
    } catch (e) {
      debugPrint('Error inicializando BookRepository: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAppSettings(AppSettings newSettings) async {
    _appSettings = newSettings;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_appSettingsKey, jsonEncode(_appSettings.toJson()));
    } catch (e) {
      debugPrint('Error guardando AppSettings: $e');
    }
    notifyListeners();
  }

  Future<int> regenerateAllCovers() async {
    int count = 0;
    for (int i = 0; i < _books.length; i++) {
      final book = _books[i];
      final newCover = await PdfService.generateCover(book.filePath, book.id);
      if (newCover != null) {
        _books[i] = book.copyWith(coverPath: newCover);
        count++;
      }
    }
    if (count > 0) {
      await _saveBooks();
      notifyListeners();
    }
    return count;
  }

  Future<void> _checkAndGenerateMissingCovers() async {
    bool hasUpdates = false;
    for (int i = 0; i < _books.length; i++) {
      final book = _books[i];
      if (book.coverPath == null || !File(book.coverPath!).existsSync()) {
        final newCover = await PdfService.generateCover(book.filePath, book.id);
        if (newCover != null) {
          _books[i] = book.copyWith(coverPath: newCover);
          hasUpdates = true;
        }
      }
    }
    if (hasUpdates) {
      await _saveBooks();
      notifyListeners();
    }
  }

  Future<void> addBook(Book book) async {
    _books.removeWhere((b) => b.id == book.id);
    _books.insert(0, book);
    await _saveBooks();
    notifyListeners();
  }

  Future<void> updateProgress(String bookId, int currentPage) async {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      final old = _books[index];
      final newPage = currentPage.clamp(1, old.totalPages);
      final newProgress = (newPage / old.totalPages).clamp(0.0, 1.0);
      
      _books[index] = old.copyWith(
        currentPage: newPage,
        progress: newProgress,
        lastReadAt: DateTime.now(),
      );
      await _saveBooks();
      notifyListeners();
    }
  }

  Future<void> deleteBook(String bookId) async {
    _books.removeWhere((b) => b.id == bookId);
    _bookmarks.removeWhere((bm) => bm.bookId == bookId);
    _notes.removeWhere((n) => n.bookId == bookId);
    await _saveBooks();
    await _saveBookmarks();
    await _saveNotes();
    notifyListeners();
  }

  // --- Marcadores ---
  List<Bookmark> getBookmarksForBook(String bookId) {
    return _bookmarks.where((bm) => bm.bookId == bookId).toList();
  }

  Future<void> addBookmark(Bookmark bookmark) async {
    _bookmarks.insert(0, bookmark);
    await _saveBookmarks();
    notifyListeners();
  }

  Future<void> removeBookmark(String bookmarkId) async {
    _bookmarks.removeWhere((bm) => bm.id == bookmarkId);
    await _saveBookmarks();
    notifyListeners();
  }

  // --- Notas ---
  List<Note> getNotesForBook(String bookId) {
    return _notes.where((n) => n.bookId == bookId).toList();
  }

  Future<void> addNote(Note note) async {
    _notes.insert(0, note);
    await _saveNotes();
    notifyListeners();
  }

  // --- Configuración de lectura ---
  Future<ReadingSettings> getSettingsForBook(String bookId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_settingsPrefix$bookId';
      final jsonStr = prefs.getString(key);
      if (jsonStr != null) {
        return ReadingSettings.fromJson(jsonDecode(jsonStr));
      }
    } catch (e) {
      debugPrint('Error cargando ReadingSettings: $e');
    }
    return ReadingSettings(
      id: 'settings_$bookId',
      bookId: bookId,
      fontFamily: _appSettings.preferredFontFamily,
      fontSize: _appSettings.defaultFontSize,
      theme: _appSettings.defaultReadingTheme,
      readingMode: _appSettings.defaultReadingMode,
    );
  }

  Future<void> saveSettingsForBook(ReadingSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_settingsPrefix${settings.bookId}';
      await prefs.setString(key, jsonEncode(settings.toJson()));
      notifyListeners();
    } catch (e) {
      debugPrint('Error guardando ReadingSettings: $e');
    }
  }

  // --- Persistencia interna ---
  Future<void> _saveBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _books.map((b) => b.toJson()).toList();
    await prefs.setString(_booksKey, jsonEncode(jsonList));
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _bookmarks.map((bm) => bm.toJson()).toList();
    await prefs.setString(_bookmarksKey, jsonEncode(jsonList));
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _notes.map((n) => n.toJson()).toList();
    await prefs.setString(_notesKey, jsonEncode(jsonList));
  }
}
