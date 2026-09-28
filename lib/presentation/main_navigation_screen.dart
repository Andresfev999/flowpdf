import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/book_repository.dart';
import 'bookmarks/bookmarks_screen.dart';
import 'home/home_screen.dart';
import 'library/library_screen.dart';
import 'settings/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final BookRepository bookRepository;

  const MainNavigationScreen({
    super.key,
    required this.bookRepository,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(bookRepository: widget.bookRepository),
          LibraryScreen(bookRepository: widget.bookRepository),
          BookmarksScreen(bookRepository: widget.bookRepository),
          SettingsScreen(bookRepository: widget.bookRepository),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        indicatorColor: AppTheme.primaryColor.withOpacity(0.18),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primaryColor),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories_rounded, color: AppTheme.primaryColor),
            label: 'Biblioteca',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmarks_outlined),
            selectedIcon: Icon(Icons.bookmarks_rounded, color: AppTheme.primaryColor),
            label: 'Marcadores',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded, color: AppTheme.primaryColor),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
