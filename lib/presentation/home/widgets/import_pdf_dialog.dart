import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/book_repository.dart';
import '../../../data/services/pdf_service.dart';
import '../../reader/reader_screen.dart';

class ImportPdfDialog extends StatefulWidget {
  final BookRepository bookRepository;

  const ImportPdfDialog({super.key, required this.bookRepository});

  @override
  State<ImportPdfDialog> createState() => _ImportPdfDialogState();
}

class _ImportPdfDialogState extends State<ImportPdfDialog> {
  bool _isProcessing = false;
  double _progress = 0.0;
  String _statusText = 'Selecciona un PDF desde tu dispositivo';

  Future<void> _pickAndProcessPdf() async {
    try {
      final picked = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (picked == null || picked.path == null) {
        return;
      }

      final file = File(picked.path!);

      setState(() {
        _isProcessing = true;
        _progress = 0.25;
        _statusText = 'Validando documento...';
      });

      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _progress = 0.55;
        _statusText = 'Analizando estructura y páginas...';
      });

      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _progress = 0.85;
        _statusText = 'Preparando experiencia de lectura...';
      });

      final book = await PdfService.parseAndImportPdf(file);
      await widget.bookRepository.addBook(book);

      setState(() {
        _progress = 1.0;
        _statusText = '¡Listo!';
      });

      await Future.delayed(const Duration(milliseconds: 200));

      if (mounted) {
        Navigator.pop(context); // Cierra diálogo
        // Abre inmediatamente el lector
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
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusText = 'Error al importar PDF: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.picture_as_pdf_rounded,
                size: 40,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Importar Libro',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _statusText,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.secondaryText,
              ),
            ),
            const SizedBox(height: 24),

            if (_isProcessing) ...[
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 12),
              Text(
                '${(_progress * 100).round()}%',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  fontSize: 13,
                ),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: _pickAndProcessPdf,
                icon: const Icon(Icons.folder_open, color: Colors.white, size: 20),
                label: Text(
                  'Seleccionar PDF',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.inter(color: AppTheme.secondaryText),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
