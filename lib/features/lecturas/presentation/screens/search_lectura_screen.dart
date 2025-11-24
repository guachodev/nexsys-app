import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexsys_app/shared/widgets/widgets.dart';

import '../providers/search_lectura.provider.dart';
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
  String filter = "todos"; // todos, registrados, sincronizados, pendientes

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchLecturaProvider);

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
                //_buildFilters(),

                /* const SizedBox(height: 8),

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
                ), */

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

/*   Widget _buildFilters() {
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        //padding: const EdgeInsets.symmetric(horizontal: 0),
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            _chip("Todos", "todos"),
            _chip("Registrados", "registrados"),
          ],
        ),
      ),
    );
  } */

  /* Widget _chip(String label, String value) {
    final selected = filter == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: Colors.blue.shade700,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.black87,
          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        onSelected: (_) => setState(() => filter = value),
      ),
    );
  } */
}
