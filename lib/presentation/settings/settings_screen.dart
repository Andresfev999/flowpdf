import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ThemeMode currentThemeMode;

  const SettingsScreen({
    super.key,
    required this.onThemeModeChanged,
    required this.currentThemeMode,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ajustes',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _buildSectionHeader('LECTURA'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined, color: AppTheme.primaryColor),
                  title: const Text('Tema oscuro de la app'),
                  subtitle: const Text('Alternar entre interfaz clara y oscura'),
                  value: widget.currentThemeMode == ThemeMode.dark ||
                      (widget.currentThemeMode == ThemeMode.system && isDark),
                  onChanged: (val) {
                    widget.onThemeModeChanged(val ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.text_fields_rounded, color: AppTheme.primaryColor),
                  title: const Text('Tipografía preferida'),
                  subtitle: const Text('Literata (Editorial)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.animation_rounded, color: AppTheme.primaryColor),
                  title: const Text('Animaciones de paso de página'),
                  subtitle: const Text('Suave e instantánea'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _buildSectionHeader('BIBLIOTECA'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.sort_rounded, color: AppTheme.primaryColor),
                  title: const Text('Ordenar libros por'),
                  subtitle: const Text('Última lectura reciente'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.view_agenda_outlined, color: AppTheme.primaryColor),
                  title: const Text('Vista de colección'),
                  subtitle: const Text('Lista vertical móvil (Recomendada)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _buildSectionHeader('INFORMACIÓN'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.auto_stories_rounded, color: AppTheme.primaryColor),
                  title: const Text('Sobre FlowPDF'),
                  subtitle: const Text('Tus PDFs. Tu ritmo.'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showAboutDialog(context),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.verified_outlined, color: AppTheme.secondaryText),
                  title: Text('Versión'),
                  subtitle: Text('1.0.0 (MVP)'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppTheme.secondaryText,
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.auto_stories, color: AppTheme.primaryColor),
            const SizedBox(width: 10),
            Text('FlowPDF', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FlowPDF transforma la lectura de PDFs en dispositivos móviles en una experiencia cómoda, limpia y adaptable tipo eReader.',
              style: GoogleFonts.inter(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            const Text(
              '• Modo Flow con extracción y reflow\n• Temas Claro, Papel, Oscuro y AMOLED\n• Sin saturación: controles invisibles al leer\n• 100% Offline-first',
              style: TextStyle(fontSize: 12, color: AppTheme.secondaryText, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
