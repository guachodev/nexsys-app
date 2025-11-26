import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/core/providers/providers.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';
import 'package:nexsys_app/shared/widgets/widgets.dart';

import '../widgets/contenido_principal.dart';

class LecturasScreen extends ConsumerWidget {
  const LecturasScreen({super.key});

  bool _isLoading(SearchStatus a, SearchStatus b) {
    return a == SearchStatus.initial ||
        a == SearchStatus.loading ||
        b == SearchStatus.initial ||
        b == SearchStatus.loading;
  }

  bool _hasError(SearchStatus a, SearchStatus b) {
    return a == SearchStatus.error || b == SearchStatus.error;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasInternet = ref.watch(networkProvider).value ?? false;

    final periodoState = ref.watch(periodoProvider);
    final rutasState = ref.watch(rutasProvider);
    Widget body;
    // ------------------------------------
    //   1. LOADING ÚNICO GLOBAL
    // ------------------------------------
    if (_isLoading(periodoState.status, rutasState.status)) {
      body = const LoadingScreen();
    }
    // ------------------------------------
    //   2. ERROR UNIFICADO
    // ------------------------------------
    else if (_hasError(periodoState.status, rutasState.status)) {
      final msg =
          periodoState.errorMessage ??
          rutasState.errorMessage ??
          "Ocurrió un error inesperado.";

      body = _Error(
        title: "¡Uy!",
        message: msg,
        onRetry: () {
          ref.read(periodoProvider.notifier).loadPeriodo();
          ref.read(rutasProvider.notifier).cargarRutas();
        },
      );
    }
    // ------------------------------------
    //   3. NO HAY PERIODO
    // ------------------------------------
    else if (periodoState.status == SearchStatus.empty) {
      body = Column(
        children: [
          const Center(child: Text('No hay periodo disponible.')),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text("Descargar"),
              onPressed: () async {
                ref.read(periodoProvider.notifier).loadPeriodo();
              },
            ),
          ),
        ],
      );
    }
    // ------------------------------------
    //   4. LISTO PARA MOSTRAR CONTENIDO
    // ------------------------------------
    else {
      body = ContenidoPrincipal(
        ref: ref,
        periodoState: periodoState,
        hasInternet: hasInternet,
        rutasState: rutasState,
      );
    }

    /* switch (periodoState.status) {
      case SearchStatus.initial:
      case SearchStatus.loading:
        body = const LoadingScreen();
        break;
      case SearchStatus.loaded:
        body = ContenidoPrincipal(
          ref: ref,
          periodoState: periodoState,
          hasInternet: hasInternet,
        );
        break;
      case SearchStatus.empty:
        body = Column(
          children: [
            const Center(child: Text('No hay periodo disponible.')),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text("Descargar"),
                onPressed: () async {
                  ref.read(periodoProvider.notifier).loadPeriodo();
                  /* if (!hasInternet) {
                  Loader.openInfoRed(
                    context,
                    "Para poder descargar las los medidores asignados, por favor conéctate a una red Wi-Fi o de datos móviles.",
                  );
                  return;
                }

                Loader.openDowloadLecturas(context);

                await ref
                    .read(descargaLecturasProvider.notifier)
                    .descargarLecturas(periodoId.toString());

                Future.microtask(() {
                  ref.read(periodoProvider.notifier).marcarDescargado();
                  //ref.read(periodoProvider.notifier).refreshAvance();
                });

                if (!context.mounted) return;
                Loader.stopLoading(context);
                Notifications.info(context, 'Se descargaron correctamente.'); */
                },
              ),
            ),
          ],
        );
        break;
      case SearchStatus.error:
        //body = Center(child: Text('Error: ${periodoState.errorMessage}'));
        body = _Error(
          message: periodoState.errorMessage ?? 'Ocurrió un error inesperado.',
          title: '¡Uy!',
          onRetry: () {
            ref.read(periodoProvider.notifier).loadPeriodo();
          },
        );
        break;
    }
     */
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: BarApp(
          title: 'Lecturas de Consumo',
          /* actions: const [
            IconButton(icon: Icon(Icons.help_outline), onPressed: null),
          ], */
        ),
        drawer: const CustomDrawer(),
        body: body,
      ),
    );
  }
}

class _Error extends StatelessWidget {
  final String message;
  final String title;
  final VoidCallback? onRetry;
  const _Error({required this.message, required this.title, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              /* decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.1),
                  ), */
              padding: const EdgeInsets.all(32),
              /*child: Lottie.asset(
                  'assets/animations/error.json',
                  height: 160,
                  repeat: true,
                ),*/
            ),

            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[700],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  shadowColor: color.withValues(alpha: 0.4),
                  elevation: 6,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
