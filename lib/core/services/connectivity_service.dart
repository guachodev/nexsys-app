import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/legacy.dart';

final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, bool>(
  (ref) => ConnectivityNotifier(),
);

class ConnectivityNotifier extends StateNotifier<bool> {
  late final StreamSubscription<ConnectivityResult> _subscription;
  final Connectivity _connectivity = Connectivity();

  ConnectivityNotifier() : super(true) {
    _init();
  }

  Future<void> _init() async {
    try {
      // Verificar conectividad inicial
      final initialResult = await _connectivity.checkConnectivity();
      final initialIsConnected = initialResult != ConnectivityResult.none;
      state = initialIsConnected;
      print('Estado inicial de conexión: $initialIsConnected');

      // Escuchar cambios en la conectividad
      _subscription =
          _connectivity.onConnectivityChanged.listen((result) {
                final isConnected = result.first != ConnectivityResult.none;

                print('Tipo de conexión: $result');
                print('¿Está conectado?: $isConnected');
                state = isConnected;
              })
              as StreamSubscription<ConnectivityResult>;
    } catch (e) {
      print('Error en connectivity: $e');
      state = false; // Asumir sin conexión en caso de error
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
