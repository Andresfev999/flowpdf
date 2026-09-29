import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateCheckerService {
  static const List<String> _baseUrls = [
    'https://apps.protondev.space',
    'http://63.250.41.149:3000',
    'http://10.0.2.2:3000',
    'http://localhost:3000',
  ];

  static Future<void> checkUpdate(
    BuildContext context, {
    required String slug,
    required int currentVersionCode,
    required String currentVersionName,
    Color accentColor = const Color(0xFF2563EB),
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: const Color(0xFF1E293B),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: accentColor),
                ),
                const SizedBox(width: 20),
                const Text(
                  'Buscando actualización...',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Map<String, dynamic>? updateData;
    String? fetchError;

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 6);

    for (final base in _baseUrls) {
      try {
        final uri = Uri.parse('$base/api/v1/apps/$slug/updates?version_code=$currentVersionCode&platform=android');
        final request = await client.getUrl(uri);
        final response = await request.close();
        if (response.statusCode == 200) {
          final body = await response.transform(utf8.decoder).join();
          updateData = jsonDecode(body) as Map<String, dynamic>;
          fetchError = null;
          break;
        } else {
          fetchError = 'Status: ${response.statusCode}';
        }
      } catch (e) {
        fetchError = e.toString();
      }
    }
    client.close();

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    if (fetchError != null && updateData == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          backgroundColor: const Color(0xFF1E293B),
          title: const Row(
            children: [
              Icon(Icons.cloud_off_rounded, color: Colors.orangeAccent),
              SizedBox(width: 10),
              Text('Sin conexión al servidor', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'No fue posible verificar actualizaciones en este momento. Por favor comprueba tu conexión a internet o intenta más tarde.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Entendido', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      return;
    }

    final hasUpdate = updateData?['has_update'] == true;
    final latestVersion = updateData?['latest_version'] ?? currentVersionName;
    final changelog = updateData?['changelog'] ?? '';
    final fileSize = updateData?['file_size'] ?? '';
    final downloadUrl = updateData?['download_url'] ?? updateData?['direct_apk_url'] ?? '';

    if (hasUpdate) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFF1E293B),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.system_update_rounded, color: Colors.greenAccent, size: 26),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '¡Nueva versión!',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Versión $latestVersion ya está disponible.',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  'Versión actual: v$currentVersionName • Tamaño: $fileSize',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                ),
                if (changelog.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Text('Novedades:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Text(
                      changelog.replaceAll('### ', '').replaceAll('- **', '• ').replaceAll('**', ''),
                      style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Más tarde', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Descargar e Instalar'),
              onPressed: () async {
                Navigator.pop(ctx);
                if (downloadUrl.isNotEmpty) {
                  final uri = Uri.parse(downloadUrl.startsWith('http') ? downloadUrl : '${_baseUrls.first}$downloadUrl');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
              },
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFF1E293B),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Colors.blueAccent, size: 26),
              ),
              const SizedBox(width: 12),
              const Text(
                'Estás al día',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            'Tu aplicación ya cuenta con la versión más reciente (v$currentVersionName).',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    }
  }
}
