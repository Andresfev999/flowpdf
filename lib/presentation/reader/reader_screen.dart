import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/book.dart';
import '../../data/models/bookmark.dart';
import '../../data/models/reading_settings.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/services/pdf_service.dart';
import 'widgets/appearance_bottom_sheet.dart';

class ReaderScreen extends StatefulWidget {
  final Book book;
  final BookRepository bookRepository;

  const ReaderScreen({
    super.key,
    required this.book,
    required this.bookRepository,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> with SingleTickerProviderStateMixin {
  late PdfViewerController _pdfViewerController;
  late ReadingSettings _settings;
  late int _currentPage;
  bool _areControlsVisible = true;
  bool _isLoading = true;

  // Flow Mode State
  String _flowPageText = '';
  bool _isExtractingFlowText = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.book.currentPage.clamp(1, widget.book.totalPages);
    _pdfViewerController = PdfViewerController();
    _settings = ReadingSettings.defaultSettings(widget.book.id);

    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final savedSettings = await widget.bookRepository.getSettingsForBook(widget.book.id);
    setState(() {
      _settings = savedSettings;
      _isLoading = false;
    });

    if (_settings.readingMode == 'flow') {
      _loadFlowPageText(_currentPage);
    }

    // Auto-ocultar controles tras 3 segundos de entrar a la lectura
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && _areControlsVisible) {
        setState(() {
          _areControlsVisible = false;
        });
      }
    });
  }

  Future<void> _loadFlowPageText(int page) async {
    setState(() {
      _isExtractingFlowText = true;
    });
    final text = await PdfService.extractFlowPageText(widget.book.filePath, page - 1);
    if (mounted) {
      setState(() {
        _flowPageText = text;
        _isExtractingFlowText = false;
      });
    }
  }

  void _onPageChanged(int newPage) {
    if (newPage < 1 || newPage > widget.book.totalPages) return;
    setState(() {
      _currentPage = newPage;
    });
    widget.bookRepository.updateProgress(widget.book.id, newPage);

    if (_settings.readingMode == 'flow') {
      _loadFlowPageText(newPage);
    } else {
      _pdfViewerController.jumpToPage(newPage);
    }
  }

  void _toggleControls() {
    setState(() {
      _areControlsVisible = !_areControlsVisible;
    });
  }

  void _toggleBookmark() async {
    final existing = widget.bookRepository
        .getBookmarksForBook(widget.book.id)
        .where((bm) => bm.page == _currentPage)
        .toList();

    if (existing.isNotEmpty) {
      await widget.bookRepository.removeBookmark(existing.first.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Marcador eliminado de la página $_currentPage'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      final newBm = Bookmark(
        id: const Uuid().v4(),
        bookId: widget.book.id,
        page: _currentPage,
        title: 'Página $_currentPage',
        createdAt: DateTime.now(),
      );
      await widget.bookRepository.addBookmark(newBm);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.bookmark_added, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text('Página $_currentPage marcada'),
              ],
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    setState(() {});
  }

  void _openAppearanceSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return AppearanceBottomSheet(
              settings: _settings,
              onSettingsChanged: (newSettings) {
                setSheetState(() {
                  _settings = newSettings;
                });
                setState(() {
                  _settings = newSettings;
                });
                widget.bookRepository.saveSettingsForBook(newSettings);
              },
            );
          },
        );
      },
    );
  }

  void _openBookmarksList() {
    final bookmarks = widget.bookRepository.getBookmarksForBook(widget.book.id);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final readerTheme = AppTheme.getReaderTheme(_settings.theme);
        return Container(
          decoration: BoxDecoration(
            color: readerTheme.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Marcadores del libro',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: readerTheme.textColor,
                ),
              ),
              const SizedBox(height: 12),
              if (bookmarks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No tienes marcadores en este libro aún.',
                      style: TextStyle(color: readerTheme.secondaryColor),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: bookmarks.length,
                    separatorBuilder: (_, __) => Divider(color: readerTheme.secondaryColor.withOpacity(0.2)),
                    itemBuilder: (context, index) {
                      final bm = bookmarks[index];
                      return ListTile(
                        leading: const Icon(Icons.bookmark, color: AppTheme.primaryColor),
                        title: Text(
                          bm.title,
                          style: TextStyle(color: readerTheme.textColor, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Página ${bm.page}',
                          style: TextStyle(color: readerTheme.secondaryColor),
                        ),
                        trailing: Icon(Icons.chevron_right, color: readerTheme.secondaryColor),
                        onTap: () {
                          Navigator.pop(ctx);
                          _onPageChanged(bm.page);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
    }

    final readerTheme = AppTheme.getReaderTheme(_settings.theme);
    final hasBookmark = widget.bookRepository
        .getBookmarksForBook(widget.book.id)
        .any((bm) => bm.page == _currentPage);

    return Scaffold(
      backgroundColor: readerTheme.backgroundColor,
      body: Stack(
        children: [
          // Vista principal de lectura
          GestureDetector(
            onTap: _toggleControls,
            child: _settings.readingMode == 'flow'
                ? _buildFlowModeView(readerTheme)
                : _buildPdfModeView(),
          ),

          // Barra Superior de Controles
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            top: _areControlsVisible ? 0 : -100,
            left: 0,
            right: 0,
            child: _buildTopBar(readerTheme, hasBookmark),
          ),

          // Barra Inferior de Controles (siempre anclada con botones Anterior y Siguiente)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(readerTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(ReaderTheme readerTheme, bool hasBookmark) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 6,
        left: 8,
        right: 8,
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: readerTheme.appBarColor.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: readerTheme.textColor),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.book.title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: readerTheme.textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.book.author,
                  style: TextStyle(
                    fontSize: 12,
                    color: readerTheme.secondaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Botón selector Modo FLOW ⭐ vs PDF
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _buildModeTab('PDF', 'pdf', readerTheme),
                _buildModeTab('FLOW ⭐', 'flow', readerTheme),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              hasBookmark ? Icons.bookmark : Icons.bookmark_border,
              color: hasBookmark ? Colors.amber : readerTheme.textColor,
            ),
            onPressed: _toggleBookmark,
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab(String label, String mode, ReaderTheme theme) {
    final isSelected = _settings.readingMode == mode;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          final newSettings = _settings.copyWith(readingMode: mode);
          setState(() {
            _settings = newSettings;
          });
          widget.bookRepository.saveSettingsForBook(newSettings);
          if (mode == 'flow') {
            _loadFlowPageText(_currentPage);
          } else {
            Future.delayed(const Duration(milliseconds: 100), () {
              _pdfViewerController.jumpToPage(_currentPage);
            });
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : theme.textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(ReaderTheme readerTheme) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: readerTheme.appBarColor.withValues(alpha: 0.96),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sección de controles expandibles (Slider, Aa y Marcadores) al tocar el centro
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _areControlsVisible ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: _currentPage.toDouble(),
                      min: 1.0,
                      max: widget.book.totalPages.toDouble(),
                      activeColor: AppTheme.primaryColor,
                      inactiveColor: readerTheme.secondaryColor.withValues(alpha: 0.3),
                      onChanged: (val) {
                        _onPageChanged(val.round());
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        icon: const Text(
                          'Aa',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        label: const Text('Formato'),
                        style: TextButton.styleFrom(foregroundColor: readerTheme.textColor),
                        onPressed: _openAppearanceSheet,
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.bookmarks_outlined, size: 18),
                        label: const Text('Marcadores'),
                        style: TextButton.styleFrom(foregroundColor: readerTheme.textColor),
                        onPressed: _openBookmarksList,
                      ),
                    ],
                  ),
                  Divider(
                    color: readerTheme.secondaryColor.withValues(alpha: 0.15),
                    height: 6,
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),

          // BARRA INFERIOR SIEMPRE VISIBLE: [◀ Anterior]  [Pág. X / Y]  [Siguiente ▶]
          Padding(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 6,
              bottom: bottomPadding > 0 ? bottomPadding : 10,
            ),
            child: Row(
              children: [
                // Botón Anterior siempre visible
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: _currentPage > 1 ? () => _onPageChanged(_currentPage - 1) : null,
                    icon: const Icon(Icons.chevron_left_rounded, size: 22),
                    label: const Text(
                      'Anterior',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: readerTheme.backgroundColor,
                      foregroundColor: readerTheme.textColor,
                      disabledForegroundColor: readerTheme.secondaryColor.withValues(alpha: 0.3),
                      disabledBackgroundColor: readerTheme.backgroundColor.withValues(alpha: 0.5),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: readerTheme.secondaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ),
                ),

                // Indicador Central de Página
                Expanded(
                  flex: 4,
                  child: GestureDetector(
                    onTap: _toggleControls,
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_currentPage / ${widget.book.totalPages}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: readerTheme.textColor,
                          ),
                        ),
                        Text(
                          '${((_currentPage / widget.book.totalPages) * 100).round()}% leído',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Botón Siguiente siempre visible
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: _currentPage < widget.book.totalPages
                        ? () => _onPageChanged(_currentPage + 1)
                        : null,
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(Icons.chevron_right_rounded, size: 22),
                    label: const Text(
                      'Siguiente',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white54,
                      disabledBackgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// MODO PDF: Visualización original del documento
  Widget _buildPdfModeView() {
    final file = File(widget.book.filePath);
    if (!file.existsSync()) {
      return Center(
        child: Text(
          'Archivo no encontrado en:\n${widget.book.filePath}',
          textAlign: TextAlign.center,
        ),
      );
    }

    return SfPdfViewer.file(
      file,
      controller: _pdfViewerController,
      initialPageNumber: _currentPage,
      pageSpacing: 0,
      enableDoubleTapZooming: true,
      canShowScrollHead: false,
      canShowScrollStatus: false,
      onPageChanged: (details) {
        if (_currentPage != details.newPageNumber) {
          setState(() {
            _currentPage = details.newPageNumber;
          });
          widget.bookRepository.updateProgress(widget.book.id, details.newPageNumber);
        }
      },
    );
  }

  /// MODO FLOW ⭐: Adaptación responsiva tipo eReader
  Widget _buildFlowModeView(ReaderTheme readerTheme) {
    if (_isExtractingFlowText) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppTheme.primaryColor),
            const SizedBox(height: 16),
            Text(
              'Adaptando página a Modo Flow...',
              style: TextStyle(color: readerTheme.secondaryColor, fontSize: 13),
            ),
          ],
        ),
      );
    }

    TextStyle textStyle;
    if (_settings.fontFamily == 'Literata') {
      textStyle = GoogleFonts.literata(
        fontSize: _settings.fontSize,
        height: _settings.lineHeight,
        color: readerTheme.textColor,
      );
    } else {
      textStyle = GoogleFonts.inter(
        fontSize: _settings.fontSize,
        height: _settings.lineHeight,
        color: readerTheme.textColor,
      );
    }

    return Container(
      color: readerTheme.backgroundColor,
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            // Swipe para cambio de página
            if (details.primaryVelocity != null) {
              if (details.primaryVelocity! < -200 && _currentPage < widget.book.totalPages) {
                _onPageChanged(_currentPage + 1);
              } else if (details.primaryVelocity! > 200 && _currentPage > 1) {
                _onPageChanged(_currentPage - 1);
              }
            }
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: _settings.margin,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado de página
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PÁGINA $_currentPage DE ${widget.book.totalPages}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                        color: readerTheme.secondaryColor,
                      ),
                    ),
                    Text(
                      '${((_currentPage / widget.book.totalPages) * 100).round()}% LEÍDO',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Contenido del Flow Engine con selección de texto nativa
                SelectableText(
                  _flowPageText,
                  style: textStyle,
                  textAlign: TextAlign.justify,
                ),

                const SizedBox(height: 40),
                Center(
                  child: Text(
                    '•  •  •',
                    style: TextStyle(color: readerTheme.secondaryColor, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
