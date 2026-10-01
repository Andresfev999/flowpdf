import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/update_checker_service.dart';
import '../../data/models/app_settings.dart';
import '../../data/repositories/book_repository.dart';

class SettingsScreen extends StatefulWidget {
  final BookRepository bookRepository;

  const SettingsScreen({
    super.key,
    required this.bookRepository,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isRegeneratingCovers = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.bookRepository,
      builder: (context, _) {
        final settings = widget.bookRepository.appSettings;
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
              // --- SECCIÓN 1: APARIENCIA GENERAL ---
              _buildSectionHeader('APARIENCIA DE LA APP'),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: Icon(
                        settings.themeMode == 'dark' || (settings.themeMode == 'system' && isDark)
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: AppTheme.primaryColor,
                      ),
                      title: const Text('Tema oscuro de la app'),
                      subtitle: Text(_getThemeModeLabel(settings.themeMode)),
                      value: settings.themeMode == 'dark' ||
                          (settings.themeMode == 'system' && isDark),
                      onChanged: (val) {
                        final newMode = val ? 'dark' : 'light';
                        widget.bookRepository.updateAppSettings(
                          settings.copyWith(themeMode: newMode),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.palette_outlined, color: AppTheme.primaryColor),
                      title: const Text('Preferencia de tema'),
                      subtitle: Text('Actualmente: ${_getThemeModeLabel(settings.themeMode)}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showThemeModeSelector(context, settings),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.color_lens_outlined, color: AppTheme.primaryColor),
                      title: const Text('Paleta de colores de la app'),
                      subtitle: Text('Tema: ${AppTheme.getPalette(settings.colorPalette).name}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: AppTheme.getPalette(settings.colorPalette).primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                      onTap: () => _showPaletteSelector(context, settings),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: AppTheme.palettes.map((p) {
                          final isSelected = settings.colorPalette == p.id;
                          return GestureDetector(
                            onTap: () {
                              widget.bookRepository.updateAppSettings(
                                settings.copyWith(colorPalette: p.id),
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: p.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: p.primary.withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                ],
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, size: 20, color: Colors.white)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- SECCIÓN 2: LECTURA PREDETERMINADA ---
              _buildSectionHeader('LECTURA PREDETERMINADA'),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.text_fields_rounded, color: AppTheme.primaryColor),
                      title: const Text('Tipografía preferida'),
                      subtitle: Text('${settings.preferredFontFamily} (Toque para cambiar)'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showFontSelector(context, settings),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.auto_stories_outlined, color: AppTheme.primaryColor),
                      title: const Text('Tema de lectura predeterminado'),
                      subtitle: Text(_getReadingThemeLabel(settings.defaultReadingTheme)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showReadingThemeSelector(context, settings),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.chrome_reader_mode_outlined, color: AppTheme.primaryColor),
                      title: const Text('Modo de lectura predeterminado'),
                      subtitle: Text(
                        settings.defaultReadingMode == 'flow'
                            ? 'Modo FLOW ⭐ (Reflow adaptativo sin zoom)'
                            : 'Modo PDF Clásico 📄 (Páginas fijas)',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showReadingModeSelector(context, settings),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.format_size_rounded, color: AppTheme.primaryColor),
                      title: const Text('Tamaño de texto inicial'),
                      subtitle: Text('${settings.defaultFontSize.toInt()} pt'),
                      trailing: SizedBox(
                        width: 140,
                        child: Slider(
                          value: settings.defaultFontSize,
                          min: 13.0,
                          max: 26.0,
                          divisions: 13,
                          activeColor: AppTheme.primaryColor,
                          onChanged: (val) {
                            widget.bookRepository.updateAppSettings(
                              settings.copyWith(defaultFontSize: val),
                            );
                          },
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.animation_rounded, color: AppTheme.primaryColor),
                      title: const Text('Paso de página animado'),
                      subtitle: Text(
                        settings.smoothPageTurn
                            ? 'Transición fluida horizontal'
                            : 'Salto directo instantáneo',
                      ),
                      value: settings.smoothPageTurn,
                      onChanged: (val) {
                        widget.bookRepository.updateAppSettings(
                          settings.copyWith(smoothPageTurn: val),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.screen_lock_portrait_outlined, color: AppTheme.primaryColor),
                      title: const Text('Mantener pantalla activa'),
                      subtitle: const Text('Evitar que la pantalla se apague mientras lees'),
                      value: settings.keepScreenOn,
                      onChanged: (val) {
                        widget.bookRepository.updateAppSettings(
                          settings.copyWith(keepScreenOn: val),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- SECCIÓN 3: BIBLIOTECA ---
              _buildSectionHeader('BIBLIOTECA'),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.sort_rounded, color: AppTheme.primaryColor),
                      title: const Text('Ordenar libros por'),
                      subtitle: Text(_getSortByLabel(settings.librarySortBy)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showSortBySelector(context, settings),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.view_agenda_outlined, color: AppTheme.primaryColor),
                      title: const Text('Vista de colección'),
                      subtitle: Text(
                        settings.libraryViewMode == 'grid'
                            ? 'Cuadrícula compacta (2 columnas)'
                            : 'Lista vertical móvil (Recomendada)',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showViewModeSelector(context, settings),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- SECCIÓN 4: MANTENIMIENTO ---
              _buildSectionHeader('MANTENIMIENTO & PORTADAS'),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
                child: Column(
                  children: [
                    ListTile(
                      leading: _isRegeneratingCovers
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            )
                          : const Icon(Icons.image_search_rounded, color: AppTheme.primaryColor),
                      title: const Text('Regenerar portadas de libros'),
                      subtitle: const Text('Vuelve a extraer la portada en alta resolución de todos los PDFs'),
                      trailing: const Icon(Icons.refresh_rounded),
                      onTap: _isRegeneratingCovers ? null : () => _handleRegenerateCovers(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.analytics_outlined, color: AppTheme.primaryColor),
                      title: const Text('Estadísticas de la biblioteca'),
                      subtitle: Text('${widget.bookRepository.books.length} libros • ${widget.bookRepository.bookmarks.length} marcadores • ${widget.bookRepository.notes.length} notas'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showStatsDialog(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- SECCIÓN 5: INFORMACIÓN ---
              _buildSectionHeader('INFORMACIÓN'),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.auto_stories_rounded, color: AppTheme.primaryColor),
                      title: const Text('Sobre FlowPDF'),
                      subtitle: const Text('Tus PDFs. Tu ritmo. Tu biblioteca personal.'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showAboutDialog(context),
                    ),
                    const Divider(height: 1),
                    const ListTile(
                      leading: Icon(Icons.verified_outlined, color: AppTheme.secondaryText),
                      title: Text('Versión'),
                      subtitle: Text('1.0.0 (Oficial Release)'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.system_update_rounded, color: AppTheme.primaryColor),
                      title: const Text('Verificar actualización'),
                      subtitle: const Text('Comprobar si hay una nueva versión de FlowPDF'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        UpdateCheckerService.checkUpdate(
                          context,
                          slug: 'flowpdf',
                          currentVersionCode: 3,
                          currentVersionName: '1.0.2',
                          accentColor: AppTheme.primaryColor,
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
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

  String _getThemeModeLabel(String mode) {
    switch (mode) {
      case 'light':
        return 'Modo Claro (Siempre activo)';
      case 'dark':
        return 'Modo Oscuro (Siempre activo)';
      case 'system':
      default:
        return 'Automático (Sigue el tema del sistema)';
    }
  }

  String _getReadingThemeLabel(String theme) {
    switch (theme) {
      case 'light':
        return 'Claro (Papiro blanco)';
      case 'dark':
        return 'Oscuro (Gris carbón)';
      case 'amoled':
        return 'AMOLED (Negro puro)';
      case 'paper':
      default:
        return 'Papel / Sepia (Cálido editorial)';
    }
  }

  String _getSortByLabel(String sortBy) {
    switch (sortBy) {
      case 'title':
        return 'Título alfabético (A - Z)';
      case 'progress':
        return 'Mayor porcentaje leído';
      case 'dateAdded':
        return 'Fecha de importación';
      case 'recent':
      default:
        return 'Última lectura reciente';
    }
  }

  // --- SELECTORES MODALES INTERACTIVOS ---

  void _showThemeModeSelector(BuildContext context, AppSettings settings) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tema de la aplicación',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Elige cómo quieres ver la interfaz de FlowPDF',
                  style: TextStyle(fontSize: 13, color: AppTheme.secondaryText),
                ),
                const SizedBox(height: 16),
                _buildRadioTile(
                  icon: Icons.brightness_auto_rounded,
                  title: 'Automático (Sistema)',
                  subtitle: 'Se ajusta a la configuración global de tu teléfono',
                  selected: settings.themeMode == 'system',
                  onTap: () {
                    widget.bookRepository.updateAppSettings(settings.copyWith(themeMode: 'system'));
                    Navigator.pop(ctx);
                  },
                ),
                _buildRadioTile(
                  icon: Icons.light_mode_rounded,
                  title: 'Modo Claro',
                  subtitle: 'Fondo blanco limpio de alto contraste diurno',
                  selected: settings.themeMode == 'light',
                  onTap: () {
                    widget.bookRepository.updateAppSettings(settings.copyWith(themeMode: 'light'));
                    Navigator.pop(ctx);
                  },
                ),
                _buildRadioTile(
                  icon: Icons.dark_mode_rounded,
                  title: 'Modo Oscuro',
                  subtitle: 'Fondo oscuro elegante para lectura nocturna',
                  selected: settings.themeMode == 'dark',
                  onTap: () {
                    widget.bookRepository.updateAppSettings(settings.copyWith(themeMode: 'dark'));
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPaletteSelector(BuildContext context, AppSettings settings) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paleta de Colores de la App',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Personaliza los acentos, botones y barras de toda la aplicación',
                  style: TextStyle(fontSize: 13, color: AppTheme.secondaryText),
                ),
                const SizedBox(height: 16),
                ...AppTheme.palettes.map((pal) {
                  final isSelected = settings.colorPalette == pal.id;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    tileColor: isSelected ? pal.primary.withOpacity(0.12) : null,
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: pal.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: pal.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    title: Text(
                      pal.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? pal.primary : null,
                      ),
                    ),
                    subtitle: Text(pal.description, style: const TextStyle(fontSize: 12)),
                    trailing: isSelected ? Icon(Icons.check_circle_rounded, color: pal.primary) : null,
                    onTap: () {
                      widget.bookRepository.updateAppSettings(
                        settings.copyWith(colorPalette: pal.id),
                      );
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFontSelector(BuildContext context, AppSettings settings) {
    final fonts = [
      {'name': 'Literata', 'desc': 'Serif editorial diseñada especialmente para libros'},
      {'name': 'Inter', 'desc': 'Sans-serif moderna, geométrica y sumamente nítida'},
      {'name': 'Merriweather', 'desc': 'Serif clásica de gran cuerpo para textos densos'},
      {'name': 'Lora', 'desc': 'Serif caligráfica contemporánea de curvas suaves'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tipografía de lectura',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Se usará por defecto en el Modo FLOW de tus libros',
                  style: TextStyle(fontSize: 13, color: AppTheme.secondaryText),
                ),
                const SizedBox(height: 16),
                ...fonts.map((f) {
                  final isSelected = settings.preferredFontFamily == f['name'];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    tileColor: isSelected ? AppTheme.primaryColor.withOpacity(0.12) : null,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor : Colors.grey.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Aa',
                        style: TextStyle(
                          color: isSelected ? Colors.white : null,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    title: Text(
                      f['name']!,
                      style: GoogleFonts.getFont(f['name']!, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(f['desc']!, style: const TextStyle(fontSize: 12)),
                    trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor) : null,
                    onTap: () {
                      widget.bookRepository.updateAppSettings(
                        settings.copyWith(preferredFontFamily: f['name']),
                      );
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReadingThemeSelector(BuildContext context, AppSettings settings) {
    final themes = [
      {'id': 'paper', 'title': 'Papel / Sepia', 'bg': const Color(0xFFFBF0D9), 'fg': const Color(0xFF5F4B32), 'desc': 'Tono cálido relajante que reduce la fatiga visual'},
      {'id': 'light', 'title': 'Claro Puro', 'bg': const Color(0xFFFFFFFF), 'fg': const Color(0xFF1A1A1A), 'desc': 'Papiro blanco nítido con máximo contraste diurno'},
      {'id': 'dark', 'title': 'Modo Oscuro', 'bg': const Color(0xFF1E1E24), 'fg': const Color(0xFFE2E2E6), 'desc': 'Carbón suave ideal para leer con poca luz'},
      {'id': 'amoled', 'title': 'AMOLED', 'bg': const Color(0xFF000000), 'fg': const Color(0xFFCECECE), 'desc': 'Negro absoluto que maximiza el ahorro de batería'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tema de lectura predeterminado',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Paleta de color con la que se abrirán tus libros nuevos',
                  style: TextStyle(fontSize: 13, color: AppTheme.secondaryText),
                ),
                const SizedBox(height: 16),
                ...themes.map((t) {
                  final isSelected = settings.defaultReadingTheme == t['id'];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    tileColor: isSelected ? AppTheme.primaryColor.withOpacity(0.12) : null,
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: t['bg'] as Color,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'A',
                        style: TextStyle(
                          color: t['fg'] as Color,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    title: Text(t['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(t['desc'] as String, style: const TextStyle(fontSize: 12)),
                    trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor) : null,
                    onTap: () {
                      widget.bookRepository.updateAppSettings(
                        settings.copyWith(defaultReadingTheme: t['id'] as String),
                      );
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReadingModeSelector(BuildContext context, AppSettings settings) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modo de lectura predeterminado',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Elige la experiencia principal para visualizar tus documentos',
                  style: TextStyle(fontSize: 13, color: AppTheme.secondaryText),
                ),
                const SizedBox(height: 16),
                _buildRadioTile(
                  icon: Icons.auto_stories_rounded,
                  title: 'Modo FLOW ⭐ (Recomendado)',
                  subtitle: 'Reflow continuo que adapta el texto a la pantalla sin zoom horizontal',
                  selected: settings.defaultReadingMode == 'flow',
                  onTap: () {
                    widget.bookRepository.updateAppSettings(settings.copyWith(defaultReadingMode: 'flow'));
                    Navigator.pop(ctx);
                  },
                ),
                _buildRadioTile(
                  icon: Icons.picture_as_pdf_rounded,
                  title: 'Modo PDF Clásico 📄',
                  subtitle: 'Muestra la página original vectorizada tal como fue diseñada',
                  selected: settings.defaultReadingMode == 'pdf',
                  onTap: () {
                    widget.bookRepository.updateAppSettings(settings.copyWith(defaultReadingMode: 'pdf'));
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSortBySelector(BuildContext context, AppSettings settings) {
    final options = [
      {'id': 'recent', 'title': 'Última lectura reciente', 'icon': Icons.access_time_rounded},
      {'id': 'title', 'title': 'Título alfabético (A - Z)', 'icon': Icons.sort_by_alpha_rounded},
      {'id': 'progress', 'title': 'Mayor porcentaje leído', 'icon': Icons.trending_up_rounded},
      {'id': 'dateAdded', 'title': 'Fecha de importación', 'icon': Icons.calendar_today_rounded},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ordenar libros por',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...options.map((opt) {
                  final isSelected = settings.librarySortBy == opt['id'];
                  return _buildRadioTile(
                    icon: opt['icon'] as IconData,
                    title: opt['title'] as String,
                    subtitle: null,
                    selected: isSelected,
                    onTap: () {
                      widget.bookRepository.updateAppSettings(
                        settings.copyWith(librarySortBy: opt['id'] as String),
                      );
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showViewModeSelector(BuildContext context, AppSettings settings) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vista de la biblioteca',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildRadioTile(
                  icon: Icons.view_agenda_rounded,
                  title: 'Lista vertical móvil (Recomendada)',
                  subtitle: 'Portadas grandes, progreso detallado y fecha de lectura',
                  selected: settings.libraryViewMode == 'list',
                  onTap: () {
                    widget.bookRepository.updateAppSettings(settings.copyWith(libraryViewMode: 'list'));
                    Navigator.pop(ctx);
                  },
                ),
                _buildRadioTile(
                  icon: Icons.grid_view_rounded,
                  title: 'Cuadrícula (Grid)',
                  subtitle: 'Vista tipo estantería con miniaturas de portadas en mosaico',
                  selected: settings.libraryViewMode == 'grid',
                  onTap: () {
                    widget.bookRepository.updateAppSettings(settings.copyWith(libraryViewMode: 'grid'));
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRadioTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: selected ? AppTheme.primaryColor.withOpacity(0.12) : null,
      leading: Icon(icon, color: selected ? AppTheme.primaryColor : AppTheme.secondaryText),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          color: selected ? AppTheme.primaryColor : null,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: selected ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor) : null,
      onTap: onTap,
    );
  }

  // --- ACCIONES DE MANTENIMIENTO ---

  Future<void> _handleRegenerateCovers(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isRegeneratingCovers = true);

    try {
      final total = await widget.bookRepository.regenerateAllCovers();
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('¡Portadas actualizadas! Se procesaron $total libro(s).'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error al regenerar portadas: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRegeneratingCovers = false);
      }
    }
  }

  void _showStatsDialog(BuildContext context) {
    final books = widget.bookRepository.books;
    final bookmarks = widget.bookRepository.bookmarks;
    final notes = widget.bookRepository.notes;
    final totalPages = books.fold<int>(0, (sum, b) => sum + b.totalPages);
    final readPages = books.fold<int>(0, (sum, b) => sum + b.currentPage);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.analytics_rounded, color: AppTheme.primaryColor),
            const SizedBox(width: 10),
            Text('Tu Biblioteca en Cifras', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('Libros importados', '${books.length}'),
            _buildStatRow('Páginas leídas', '$readPages / $totalPages'),
            _buildStatRow('Marcadores guardados', '${bookmarks.length}'),
            _buildStatRow('Notas registradas', '${notes.length}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Entendido')),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        ],
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
              'Tus PDFs. Tu ritmo. Tu biblioteca personal tipo eReader.',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 12),
            const Text(
              'FlowPDF transforma documentos PDF estáticos en una experiencia fluida, adaptable y ergonómica inspirada en los mejores lectores digitales del mundo.',
              style: TextStyle(fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 12),
            const Text(
              'Desarrollado con arquitectura limpia, Flutter nativo y Android PdfRenderer.',
              style: TextStyle(fontSize: 11, color: AppTheme.secondaryText),
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
