import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/book_repository.dart';
import 'presentation/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuración de barra de estado y orientación móvil
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final bookRepository = BookRepository();
  await bookRepository.init();

  runApp(FlowPdfApp(bookRepository: bookRepository));
}

class FlowPdfApp extends StatelessWidget {
  final BookRepository bookRepository;

  const FlowPdfApp({super.key, required this.bookRepository});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: bookRepository,
      builder: (context, _) {
        final settings = bookRepository.appSettings;
        final currentThemeMode = settings.themeModeEnum;
        final paletteId = settings.colorPalette;

        return MaterialApp(
          title: 'FlowPDF',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getLightTheme(paletteId),
          darkTheme: AppTheme.getDarkTheme(paletteId),
          themeMode: currentThemeMode,
          home: MainNavigationScreen(
            bookRepository: bookRepository,
          ),
        );
      },
    );
  }
}
