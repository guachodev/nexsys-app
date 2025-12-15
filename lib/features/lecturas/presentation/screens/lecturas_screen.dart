import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/core/providers/providers.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';
import 'package:nexsys_app/shared/widgets/widgets.dart';

import '../widgets/contenido_principal.dart';

class LecturasScreen extends ConsumerStatefulWidget {
  const LecturasScreen({super.key});

  @override
  ConsumerState<LecturasScreen> createState() => _LecturasScreenState();
}

class _LecturasScreenState extends ConsumerState<LecturasScreen> {
  @override
  void initState() {
    super.initState();

    // 🔹 Ejecutar cargas solo una vez al entrar
    Future.microtask(() {
      final periodoState = ref.read(periodoProvider);
      final rutasState = ref.read(rutasProvider);
      final novedadesState = ref.read(novedadesProvider);

      if (periodoState.status == SearchStatus.initial ||
          periodoState.status == SearchStatus.empty) {
        ref.read(periodoProvider.notifier).loadPeriodo();
      }

      if (rutasState.status == SearchStatus.initial) {
        ref.read(rutasProvider.notifier).cargarRutas();
      }

      if (novedadesState.status == SearchStatus.initial) {
        ref.read(novedadesProvider.notifier).loadNovedades();
      }
    });
  }

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
  Widget build(BuildContext context) {
    Widget body;

    final hasInternet = ref.watch(networkProvider).value ?? false;
    final periodoState = ref.watch(periodoProvider);
    final rutasState = ref.watch(rutasProvider);
    final novedadesState = ref.watch(novedadesProvider);
    final cerrado = periodoState.periodo?.cerrado ?? false;

    // 1️⃣ LOADING GLOBAL
    if (_isLoading(
      periodoState.status,
      rutasState.status,
      novedadesState.status,
    )) {
      body = const LoadingIndicator(
        title: "Cargando lecturas...",
        subtitle: "Por favor, espere unos segundos",
      );
    }
    // 2️⃣ ERROR UNIFICADO
    else if (_hasError(
      periodoState.status,
      rutasState.status,
      novedadesState.status,
    )) {
      final msg = periodoState.errorMessage?.isNotEmpty == true
          ? periodoState.errorMessage
          : rutasState.errorMessage?.isNotEmpty == true
          ? rutasState.errorMessage
          : novedadesState.errorMessage?.isNotEmpty == true
          ? novedadesState.errorMessage
          : "Ocurrió un error inesperado.";

      body = ErrorState(
        subtitle: msg.toString(),
        onRetry: () {
          ref.read(periodoProvider.notifier).loadPeriodo();
          ref.read(rutasProvider.notifier).cargarRutas();
          ref.read(novedadesProvider.notifier).loadNovedades();
        },
      );
    }
    // 3️⃣ NO HAY PERÍODO
    else if (periodoState.status == SearchStatus.empty) {
      body = EmptyState(
        icon: Icons.calendar_month_outlined,
        title: 'No hay período activo',
        subtitle: 'Por favor, intenta nuevamente más tarde.',
        onRetry: () => ref.read(periodoProvider.notifier).loadPeriodo(),
      );
    }
    // 4️⃣ PERÍODO CERRADO
    else if (cerrado) {
      body = Padding(
        padding: const EdgeInsets.all(16),
        child: ErrorState(
          title: 'Período finalizado',
          subtitle: 'El período ha sido cerrado y no permite modificaciones.',
          icon: Icons.info_outline,
          onRetry: () {
            ref.read(periodoProvider.notifier).loadPeriodo();
            ref.read(rutasProvider.notifier).cargarRutas();
            ref.read(novedadesProvider.notifier).loadNovedades();
          },
        ),
      );
    }
    // 5️⃣ CONTENIDO NORMAL
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
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(periodoProvider.notifier).loadPeriodo();
          await ref.read(rutasProvider.notifier).cargarRutas();
          await ref.read(novedadesProvider.notifier).loadNovedades();
        },
        child: body,
      ),
    );
  }
}
