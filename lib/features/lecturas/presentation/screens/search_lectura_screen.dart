import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';
import 'package:nexsys_app/shared/widgets/widgets.dart';

import '../widgets/filters_chip_list.dart';
import '../widgets/search_bar_with_filters .dart';
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
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchLecturaProvider);
    final rutas = ref.watch(rutasProvider);
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
                _buildFilters(rutas.rutas),

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
                Expanded(child: SearchContent(searchState: searchState,)),
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
        setState(() => selectedFilter = id);
        ref.read(searchLecturaProvider.notifier).selectRuta(id);
      },
    );
  }

  /* Widget _chip(String label, int value) {
    final bool selected = selectedFilter == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        backgroundColor: Colors.white,
        selectedColor: Colors.blue.shade700,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.black87,
          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onSelected: (_) {
          setState(() => selectedFilter = value);
          ref.read(searchLecturaProvider.notifier).selectRuta(selectedFilter);
          /*  if (selectedFilter == -1) {
            ref.read(searchLecturaProvider.notifier).allFilter();
          } else {
            ref
                .read(searchLecturaProvider.notifier)
                .filterByRutaId(selectedFilter);
          } */
        },
      ),
    );
  } */
}
