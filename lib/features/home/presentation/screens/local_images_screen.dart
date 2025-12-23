import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexsys_app/features/home/presentation/presentation.dart';
import 'package:nexsys_app/shared/widgets/widgets.dart';

class LocalImagesScreen extends ConsumerWidget {
  const LocalImagesScreen({super.key});
  void _showImagePreview(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              /// Imagen con zoom
              InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Center(
                  child: Image.file(File(imagePath), fit: BoxFit.contain),
                ),
              ),

              /// Botón cerrar
              Positioned(
                top: 40,
                right: 20,
                child: Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesAsync = ref.watch(localImagesProvider);

    return Scaffold(
      appBar: BarApp(
        title: 'Imágenes locales',
        /* actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              ref.read(localImagesProvider.notifier).clearAll();
            },
          ),
        ], */
        //Center(child: Text('No hay imágenes'))
      ),
      body: imagesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (images) {
          if (images.isEmpty) {
            return const EmptyState(
              title: 'No hay imágenes',
              icon: Icons.image_search_rounded,
              subtitle: 'No se encontraron imagenes locales',
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final imagePath = images[index];

              return GestureDetector(
                onTap: () => _showImagePreview(context, imagePath.file.path),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(imagePath.file, fit: BoxFit.cover),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
