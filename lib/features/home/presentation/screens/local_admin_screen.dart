import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexsys_app/core/services/services.dart';
import 'package:nexsys_app/core/theme/theme.dart';
import 'package:nexsys_app/core/utils/utils.dart';
import 'package:nexsys_app/features/home/presentation/presentation.dart';
import 'package:nexsys_app/shared/widgets/widgets.dart';

class LocalAdminScreen extends ConsumerWidget {
  const LocalAdminScreen({super.key});

  void mostrarDialogoResetDB(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color.fromARGB(255, 10, 10, 10).withValues(alpha: .8),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Ícono destructivo
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.red.shade600,
                    size: 42,
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  "Resetear base de datos",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Text(
                  "Estás a punto de borrar toda la información local del dispositivo, incluyendo lecturas pendientes e imágenes almacenadas.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),

                const SizedBox(height: 28),

                /// Botones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancelar",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          ref
                              .read(localAdminProvider.notifier)
                              .clearLocalData();
                        },
                        child: const Text(
                          "Eliminar",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<LocalAdminState>(localAdminProvider, (prev, next) {
      if (next.isLoading && !(prev?.isLoading ?? false)) {
        Loader.openFullLoading(context);
      } else if (!next.isLoading && (prev?.isLoading ?? true)) {
        Loader.stopLoading(context);
      }

      /// Mensajes
      final msg = next.message;
      if (msg != null && msg != prev?.message) {
        if (msg.type == LocalAdminMessageType.success) {
          Notifications.success(context, msg.text);
        } else {
          Notifications.error(context, msg.text);
        }
      }
    });

    return Scaffold(
      appBar: BarApp(title: 'Administración local'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Header(),

          const SizedBox(height: 24),

          /// ===========================
          /// MANTENIMIENTO
          /// ===========================
          const _SectionTitle('Mantenimiento'),

          EnterpriseActionButton(
            icon: Icons.history_rounded,
            title: 'Recuperar lecturas',
            subtitle:
                'Reinicia el estado a registrado cuando no fueron sincronizados',
            color: Colors.indigo,
            onTap: () => ref
                .read(localAdminProvider.notifier)
                .recoverAndGetPendingSync(),
          ),

          /* EnterpriseActionButton(
            icon: Icons.history_rounded,
            title: 'Resetear lecturas',
            subtitle: 'Reinicia el estado de descarga de todas las lecturas',
            color: Colors.indigo,
            onTap: () {
              Notifications.success(
                context,
                'Lecturas reseteadas correctamente',
              );
            },
          ), */
          const SizedBox(height: 12),

          EnterpriseActionButton(
            icon: Icons.backup_rounded,
            title: 'Backup base de datos',
            subtitle: 'Exporta la base local a un archivo seguro',
            color: Colors.green,
            onTap: () => ref.read(localAdminProvider.notifier).createBackup(),
          ),

          const SizedBox(height: 32),

          /// ===========================
          /// MULTIMEDIA
          /// ===========================
          const _SectionTitle('Multimedia'),

          EnterpriseActionButton(
            icon: Icons.photo_library_rounded,
            title: 'Galería de imágenes',
            subtitle: 'Ver imágenes almacenadas localmente',
            color: Colors.purple,
            onTap: () => context.push('/admin/local/images'),
          ),
          const SizedBox(height: 12),
          EnterpriseActionButton(
            icon: Icons.folder_zip_rounded,
            title: "Exportar imágenes",
            subtitle: "ZIP (.webp)",
            onTap: () async {
              final zipFile = await ImageService.exportImagesAsZip();

              if (zipFile == null || !await zipFile.exists()) {
                Notifications.error(context, "No hay imágenes para exportar");
                return;
              }

              final bytes = await zipFile.readAsBytes();

              final outputPath = await FilePicker.platform.saveFile(
                dialogTitle: 'Guardar imágenes en ZIP',
                fileName: zipFile.path.split('/').last,
                bytes: bytes,
                type: FileType.custom,
                allowedExtensions: ['zip'],
              );

              if (!context.mounted) return;

              if (outputPath == null) {
                Notifications.error(context, "Exportación cancelada");
                return;
              }

              Notifications.success(
                context,
                "Imágenes exportadas correctamente",
              );
            },
            color: Colors.indigo,
          ),

          const SizedBox(height: 32),

          /// ===========================
          /// ZONA DE RIESGO
          /// ===========================
          const _SectionTitle('Zona de riesgo', danger: true),

          EnterpriseActionButton(
            icon: Icons.delete_forever_rounded,
            title: 'Resetear base de datos',
            subtitle: 'Elimina completamente los datos locales',
            color: Colors.red,
            danger: true,
            onTap: () => mostrarDialogoResetDB(context, ref),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.blue.shade50,
          child: const Icon(Icons.storage, color: Colors.blue),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Base de datos local',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Gestión y mantenimiento',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}

class EnterpriseActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool danger;

  const EnterpriseActionButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        borderRadius: BorderRadius.circular(10),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.58),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
          focusColor: Colors.white,
          hoverColor: Colors.white,
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: danger ? Colors.red : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DatabaseSizeCard extends StatelessWidget {
  final double sizeMb;
  final double maxMb;

  const DatabaseSizeCard({super.key, required this.sizeMb, this.maxMb = 100});

  @override
  Widget build(BuildContext context) {
    final percent = (sizeMb / maxMb).clamp(0.0, 1.0);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uso de almacenamiento',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${sizeMb.toStringAsFixed(2)} MB usados',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: percent, minHeight: 10),
            ),
            const SizedBox(height: 8),
            Text(
              percent > 0.8 ? '⚠ Se recomienda limpieza' : 'Estado óptimo',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final bool danger;

  const _SectionTitle(this.text, {this.danger = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: danger ? Colors.red : Colors.grey.shade600,
        ),
      ),
    );
  }
}
