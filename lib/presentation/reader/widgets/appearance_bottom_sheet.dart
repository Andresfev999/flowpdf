import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/reading_settings.dart';

class AppearanceBottomSheet extends StatelessWidget {
  final ReadingSettings settings;
  final ValueChanged<ReadingSettings> onSettingsChanged;

  const AppearanceBottomSheet({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final readerTheme = AppTheme.getReaderTheme(settings.theme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: readerTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ajustes de Lectura',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: readerTheme.textColor,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: readerTheme.secondaryColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tamaño de Fuente (A ---●--- A)
            Row(
              children: [
                Text(
                  'A',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: readerTheme.textColor,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: settings.fontSize,
                    min: 13.0,
                    max: 26.0,
                    divisions: 13,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (val) {
                      onSettingsChanged(settings.copyWith(fontSize: val));
                    },
                  ),
                ),
                Text(
                  'A',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: readerTheme.textColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Fuente (Literata vs Inter)
            Text(
              'Tipografía',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: readerTheme.secondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildFontOption(
                  name: 'Literata (Editorial)',
                  fontFamily: 'Literata',
                  isSelected: settings.fontFamily == 'Literata',
                  readerTheme: readerTheme,
                ),
                const SizedBox(width: 10),
                _buildFontOption(
                  name: 'Inter (Moderno)',
                  fontFamily: 'Inter',
                  isSelected: settings.fontFamily == 'Inter',
                  readerTheme: readerTheme,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Interlineado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Interlineado',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: readerTheme.secondaryColor,
                  ),
                ),
                Text(
                  '${settings.lineHeight.toStringAsFixed(1)}x',
                  style: TextStyle(color: readerTheme.secondaryColor, fontSize: 12),
                ),
              ],
            ),
            Slider(
              value: settings.lineHeight,
              min: 1.2,
              max: 2.2,
              divisions: 5,
              activeColor: AppTheme.primaryColor,
              onChanged: (val) {
                onSettingsChanged(settings.copyWith(lineHeight: val));
              },
            ),

            // Márgenes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Márgenes laterales',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: readerTheme.secondaryColor,
                  ),
                ),
                Text(
                  '${settings.margin.round()}px',
                  style: TextStyle(color: readerTheme.secondaryColor, fontSize: 12),
                ),
              ],
            ),
            Slider(
              value: settings.margin,
              min: 10.0,
              max: 32.0,
              divisions: 11,
              activeColor: AppTheme.primaryColor,
              onChanged: (val) {
                onSettingsChanged(settings.copyWith(margin: val));
              },
            ),

            const SizedBox(height: 8),

            // Temas (Claro, Papel, Oscuro, AMOLED)
            Text(
              'Tema de Fondo',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: readerTheme.secondaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildThemeChip(
                  id: 'light',
                  label: 'Claro',
                  bgColor: const Color(0xFFFAFAFA),
                  textColor: const Color(0xFF18181B),
                  isSelected: settings.theme == 'light',
                ),
                _buildThemeChip(
                  id: 'paper',
                  label: 'Papel',
                  bgColor: const Color(0xFFF5EFEB),
                  textColor: const Color(0xFF3E2723),
                  isSelected: settings.theme == 'paper',
                ),
                _buildThemeChip(
                  id: 'dark',
                  label: 'Oscuro',
                  bgColor: const Color(0xFF18181B),
                  textColor: const Color(0xFFE4E4E7),
                  isSelected: settings.theme == 'dark',
                ),
                _buildThemeChip(
                  id: 'amoled',
                  label: 'AMOLED',
                  bgColor: const Color(0xFF000000),
                  textColor: const Color(0xFFD4D4D8),
                  isSelected: settings.theme == 'amoled',
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildFontOption({
    required String name,
    required String fontFamily,
    required bool isSelected,
    required ReaderTheme readerTheme,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          onSettingsChanged(settings.copyWith(fontFamily: fontFamily));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor.withOpacity(0.15) : Colors.transparent,
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : readerTheme.secondaryColor.withOpacity(0.3),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.primaryColor : readerTheme.textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeChip({
    required String id,
    required String label,
    required Color bgColor,
    required Color textColor,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        onSettingsChanged(settings.copyWith(theme: id));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.withOpacity(0.4),
            width: isSelected ? 2.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check, size: 14, color: AppTheme.primaryColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
