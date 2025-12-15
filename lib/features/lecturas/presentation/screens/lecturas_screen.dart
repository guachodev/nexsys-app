import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/core/providers/providers.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';
import 'package:nexsys_app/shared/widgets/widgets.dart';

import '../widgets/contenido_principal.dart';

class LecturasScreen extends ConsumerWidget {
  const LecturasScreen({super.key});

  bool _isLoading(SearchStatus a, SearchStatus b, SearchStatus c) {
    return a == SearchStatus.initial ||
        a == SearchStatus.loading ||
        b == SearchStatus.initial ||
        b == SearchStatus.loading ||
        c == SearchStatus.initial ||
        c == SearchStatus.loading;
  }

  bool _hasError(SearchStatus a, SearchStatus b, SearchStatus c) {
    return a == SearchStatus.error ||
        b == SearchStatus.error ||
        c == SearchStatus.error;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget body;
    final hasInternet = ref.watch(networkProvider).value ?? false;
    final periodoState = ref.watch(periodoProvider);
    final rutasState = ref.watch(rutasProvider);
    final novedadState = ref.watch(novedadesProvider);

    //   1. LOADING ÚNICO GLOBAL
    if (_isLoading(
      periodoState.status,
      rutasState.status,
      novedadState.status,
    )) {
      body = LoadingIndicator(
        title: "Cargando lecturas...",
        subtitle: "Por favor, espere unos segundos",
      );
    }
    //   2. ERROR UNIFICADO
    else if (_hasError(
      periodoState.status,
      rutasState.status,
      novedadState.status,
    )) {
      final msg = (periodoState.errorMessage?.isNotEmpty == true)
          ? periodoState.errorMessage
          : (rutasState.errorMessage?.isNotEmpty == true)
          ? rutasState.errorMessage
          : (novedadState.errorMessage?.isNotEmpty == true)
          ? novedadState.errorMessage
          : "Ocurrió un error inesperado.";

      body = ErrorState(
        subtitle: msg.toString(),
        onRetry: () => {
          ref.read(periodoProvider.notifier).loadPeriodo(),
          ref.watch(rutasProvider.notifier).cargarRutas(),
          ref.watch(novedadesProvider.notifier).loadNovedades(),
        },
      );
    }
    //   3. NO HAY PERIODO
    else if (periodoState.status == SearchStatus.empty) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Imagen placeholder
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text("IMAGE", style: TextStyle(fontSize: 18)),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Result not found",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              const Text(
                "Try searching for something else.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 40),
              // Botón Try Again
              SizedBox(
                width: 180,
                height: 50,
                child: ElevatedButton(
                  onPressed: () =>
                      ref.read(periodoProvider.notifier).loadPeriodo(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Try Again",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      /* Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Imagen placeholder
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text("IMAGE", style: TextStyle(fontSize: 20)),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Something went wrong",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              const Text(
                "Please try again later.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 40),

              // Botón
              SizedBox(
                width: 180,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Try Again",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ); */
      /* Container(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/svg/addUsers.svg', height: 200),
                const SizedBox(height: 32),
                const Text(
                  "No hay período activo",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Por favor, espera a que se active un nuevo período de lecturas.",
                  //style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                OutlinedButton(
                  onPressed: () =>
                      ref.read(periodoProvider.notifier).loadPeriodo(),
                  child: const Text("Reintentar"),
                ),
              ],
            ),
          ),
        ),
      ); */
    }
    //   4. LISTO PARA MOSTRAR CONTENIDO
    else {
      body = ContenidoPrincipal(
        ref: ref,
        periodoState: periodoState,
        hasInternet: hasInternet,
        rutasState: rutasState,
      );
    }

    return Scaffold(
      appBar: const BarApp(title: 'Lecturas asignadas'),
      drawer: const CustomDrawer(),
      body: body,
    );
  }

   }
