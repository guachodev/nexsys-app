import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:nexsys_app/core/services/services.dart';

final localImagesProvider =
    StateNotifierProvider<LocalImagesNotifier, AsyncValue<List<LocalImage>>>(
      (ref) => LocalImagesNotifier(),
    );

class LocalImagesNotifier extends StateNotifier<AsyncValue<List<LocalImage>>> {
  LocalImagesNotifier() : super(const AsyncLoading()) {
    loadImages();
  }

  Future<void> loadImages() async {
    try {
      final images = await ImageService.getLocalImages();
      state = AsyncData(images);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> deleteImage(LocalImage image) async {
    await ImageService.deleteImage(image.file);
    await loadImages();
  }

  Future<void> clearAll() async {
    await ImageService.clearAllImages();
    await loadImages();
  }
}
