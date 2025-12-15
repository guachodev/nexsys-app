import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexsys_app/core/utils/utils.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';
import 'package:nexsys_app/shared/widgets/widgets.dart';

import '../widgets/filters_chip_list.dart';
import '../widgets/search_bar_with_filters.dart';
import '../widgets/search_content.dart';

class SearchLecturaScreen extends ConsumerStatefulWidget {
  const SearchLecturaScreen({super.key});

  @override
  ConsumerState<SearchLecturaScreen> createState() =>
      _LecturasListScreenState();
}

class _LecturasListScreenState extends ConsumerState<SearchLecturaScreen> {
  String searchQuery = "";
  int selectedFilter = -1;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final rutasState = ref.read(rutasProvider);
   
      if (!rutasState.tieneRutasAbiertas) {
        
        Notifications.error(
          context,
          "No existen rutas abiertas para realizar búsquedas y registrar lecturas.",
        );
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchLecturaProvider);
    final rutasState = ref.watch(rutasProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: BarApp(title: 'Buscar Medidor'),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                SearchBarWithFilters(ref: ref),
                // 🔹 FILTROS
                _buildFilters(rutasState.rutas),

                const SizedBox(height: 8),

                // 🔸 TOTAL
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Resultados: ${searchState.lecturas.length}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(child: SearchContent(searchState: searchState)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FILTROS MODERNOS
  // ---------------------------------------------------------------------------

  Widget _buildFilters(List<Ruta> rutas) {
    // Si no hay rutas o solo hay 1 → no mostrar nada
    /*  if (rutas.length <= 1) {
      return const SizedBox.shrink();
    } */

    /* return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            // _chip("Todas", -1),
            ...rutas.map((r) {
              return _chip(r.detalle, r.id);
            }),
          ],
        ),
      ),
    ); */

    return FiltersChipList(
      items: rutas,
      selectedId: selectedFilter,
      labelBuilder: (r) => r.detalle,
      valueBuilder: (r) => r.id,
      onSelected: (id) {
        final rutasState = ref.read(rutasProvider);

        // 🔒 Caso: Todas las rutas
        if (id == -1) {
          if (!rutasState.tieneRutasAbiertas) {
            Notifications.warning(
              context,
              "No hay rutas abiertas disponibles.",
            );
            return;
          }

          setState(() => selectedFilter = -1);
          ref
              .read(searchLecturaProvider.notifier)
              .selectRutas(rutasState.rutasAbiertas.map((r) => r.id).toList());
          return;
        }

        // 🔒 Ruta cerrada
        final ruta = rutas.firstWhere((r) => r.id == id);
        if (ruta.cerrado) {
          Notifications.error(
            context,
            "No se puede buscar en una ruta cerrada.",
          );
          return;
        }

        // ✅ Ruta válida
        setState(() => selectedFilter = id);
        ref.read(searchLecturaProvider.notifier).selectRuta(id);
      },
    );
  }
}
