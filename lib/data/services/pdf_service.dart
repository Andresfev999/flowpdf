import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/book.dart';

class PdfService {
  static const MethodChannel _coverChannel = MethodChannel('com.flowpdf.app/pdf_cover');

  /// Genera una imagen de portada renderizando la primera página del PDF
  static Future<String?> generateCover(String pdfPath, String bookId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final coversDir = Directory(p.join(appDir.path, 'covers'));
      if (!await coversDir.exists()) {
        await coversDir.create(recursive: true);
      }

      final outputPath = p.join(coversDir.path, 'cover_$bookId.jpg');

      // Si ya existe la portada generada, reutilizarla
      if (await File(outputPath).exists()) {
        return outputPath;
      }

      // En Android, invocar el PdfRenderer nativo
      if (!kIsWeb && Platform.isAndroid) {
        final result = await _coverChannel.invokeMethod<String>('renderFirstPage', {
          'pdfPath': pdfPath,
          'outputPath': outputPath,
        });
        if (result != null && await File(result).exists()) {
          return result;
        }
      }
    } catch (e) {
      debugPrint('Error generando portada nativa para $pdfPath: $e');
    }
    return null;
  }

  /// Analiza un archivo PDF local, extrae metadatos y genera la portada
  static Future<Book> parseAndImportPdf(File originalFile) async {
    final bytes = await originalFile.readAsBytes();
    final document = PdfDocument(inputBytes: bytes);

    final totalPages = document.pages.count;
    final docInfo = document.documentInformation;

    // Obtener título o usar nombre del archivo
    String title = docInfo.title.trim();
    if (title.isEmpty) {
      title = p.basenameWithoutExtension(originalFile.path);
    }

    String author = docInfo.author.trim();
    if (author.isEmpty) {
      author = 'Autor desconocido';
    }

    // Copiar el archivo al almacenamiento persistente de la app
    final appDir = await getApplicationDocumentsDirectory();
    final booksDir = Directory(p.join(appDir.path, 'books'));
    if (!await booksDir.exists()) {
      await booksDir.create(recursive: true);
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final persistentFilePath = p.join(booksDir.path, '${id}_${p.basename(originalFile.path)}');
    await originalFile.copy(persistentFilePath);

    document.dispose();

    // Generar imagen de portada real desde la primera página
    final coverPath = await generateCover(persistentFilePath, id);

    return Book(
      id: id,
      title: title,
      author: author,
      filePath: persistentFilePath,
      coverPath: coverPath,
      totalPages: totalPages > 0 ? totalPages : 1,
      currentPage: 1,
      progress: 0.0,
      lastReadAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  /// Flow Engine: Extrae y limpia el texto de una página específica para lectura adaptativa
  static Future<String> extractFlowPageText(String filePath, int pageIndex) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return 'No se pudo cargar el archivo PDF.';
      }

      final bytes = await file.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);

      if (pageIndex < 0 || pageIndex >= document.pages.count) {
        document.dispose();
        return '';
      }

      final extractor = PdfTextExtractor(document);
      final rawText = extractor.extractText(startPageIndex: pageIndex, endPageIndex: pageIndex);
      document.dispose();

      // Limpieza y reflow del texto: unir líneas rotas artificiales y preservar párrafos
      return _reflowText(rawText);
    } catch (e) {
      debugPrint('Error extrayendo texto flow: $e');
      return 'No se pudo extraer el texto de esta página para el Modo Flow.';
    }
  }

  /// Limpia saltos de línea duros producidos por el layout de columnas de un PDF
  static String _reflowText(String raw) {
    if (raw.trim().isEmpty) {
      return 'Esta página no contiene texto procesable (posible imagen o gráfico). Cambia a Modo PDF para ver el original.';
    }

    final lines = raw.split('\n');
    final buffer = StringBuffer();
    bool prevEndedWithHyphen = false;

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        // Párrafo nuevo
        buffer.write('\n\n');
        prevEndedWithHyphen = false;
        continue;
      }

      if (prevEndedWithHyphen) {
        buffer.write(trimmed);
      } else {
        if (buffer.isNotEmpty && !buffer.toString().endsWith('\n\n') && !buffer.toString().endsWith(' ')) {
          buffer.write(' ');
        }
        buffer.write(trimmed);
      }

      // Si la línea termina en guion '-', probablemente la palabra se cortó al final de línea
      if (trimmed.endsWith('-')) {
        prevEndedWithHyphen = true;
      } else {
        prevEndedWithHyphen = false;
      }
    }

    return buffer.toString().replaceAll('  ', ' ');
  }
}
