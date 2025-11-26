import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';

final productProvider = StateNotifierProvider.autoDispose
    .family<ProductNotifier, ProductState, String>((ref, productId) {
      final repo = LecturasRepositoryImpl();
      final token = ref.watch(authProvider).user!.token;
      return ProductNotifier(productId: productId, repo: repo, token: token);
    });

class ProductNotifier extends StateNotifier<ProductState> {
  final LecturasRepositoryImpl repo;
  final String token;

  ProductNotifier({
    required String productId,
    required this.repo,
    required this.token,
  }) : super(ProductState(id: productId)) {
    debugPrint('Id => ${state.id}');
    loadProduct();
  }

  Lectura newEmptyLectura() {
    return Lectura(
      id: -1,
      medidor: '',
      cuenta: 0,
      propietario: '',
      cedula: '',
      lecturaAnterior: 0,
      novedadId: -1, rutaId: -1, promedioConsumo: -1, 
    );
  }

  Future<void> loadProduct() async {
    try {
      if (state.id == 'new') {
        state = state.copyWith(isLoading: false, lectura: newEmptyLectura());
        return;
      }
      final lectura = await repo.getLecturaById(int.parse(state.id));

      print(lectura!.imagenes);

      state = state.copyWith(isLoading: false, lectura: lectura);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      debugPrint(e.toString());
    }
  }
}

class ProductState {
  final String id;
  final Lectura? lectura;
  final bool isLoading;
  final bool isSaving;
  final String errorMessage;
  ProductState({
    required this.id,
    this.lectura,
    this.isLoading = true,
    this.isSaving = false,
    this.errorMessage = '',
  });

  ProductState copyWith({
    String? id,
    Lectura? lectura,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
  }) => ProductState(
    id: id ?? this.id,
    lectura: lectura ?? this.lectura,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}
