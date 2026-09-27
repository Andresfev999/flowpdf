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

class FlowPdfApp extends StatefulWidget {
  final BookRepository bookRepository;

  const FlowPdfApp({super.key, required this.bookRepository});

  @override
  State<FlowPdfApp> createState() => _FlowPdfAppState();
}

class _FlowPdfAppState extends State<FlowPdfApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _updateThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlowPDF',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: MainNavigationScreen(
        bookRepository: widget.bookRepository,
        onThemeModeChanged: _updateThemeMode,
        currentThemeMode: _themeMode,
      ),
    );
  }
}
