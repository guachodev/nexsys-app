import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';
import 'package:nexsys_app/shared/widgets/widgets.dart';

import '../widgets/filters_chip_list.dart';

class LecturaRegistardaScreen extends ConsumerStatefulWidget {
  const LecturaRegistardaScreen({super.key});

  @override
  ConsumerState<LecturaRegistardaScreen> createState() =>
      _LecturasListScreenState();
}

class _LecturasListScreenState extends ConsumerState<LecturaRegistardaScreen> {
  String searchQuery = "";
  int selectedFilter = -1;

  @override
  void initState() {
    super.initState();

    // 🔹 Cargar lecturas automáticamente al entrar a la pantalla
    Future.microtask(() {
      ref.read(lecturasRegistradoslProvider.notifier).filtrarPorRegistrado(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lecturasState = ref.watch(lecturasRegistradoslProvider);
    final rutasState = ref.watch(rutasProvider);

    final filtered = lecturasState.lecturas.where((l) {
      final matchSearch =
          l.cuenta.toString().contains(searchQuery) ||
          l.medidor.contains(searchQuery) ||
          l.propietario.contains(searchQuery);

      if (!matchSearch) return false;

      if (selectedFilter != -1 && l.rutaId != selectedFilter) {
        return false;
      }
      return true;
    }).toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: RefreshIndicator(
        onRefresh: () async =>
            ref.read(lecturasLocalProvider.notifier).filtrarPorRegistrado(1),
        child: Scaffold(
          appBar: BarApp(title: "Editar lecturas"),
          body:  lecturasState.status == SearchStatus.loading ||
              lecturasState.status == SearchStatus.initial
          ? LoadingIndicator(subtitle: 'Cargando lecturas espere un momento')
          :Column(
            children: [
              const SizedBox(height: 10),

              // 🔍 BUSCADOR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Buscar por cuenta, medidor o nombre...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onChanged: (value) => setState(() => searchQuery = value),
                ),
              ),
              _buildFilters(rutasState.rutas),
              // 🔸 TOTAL
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Resultados: ${filtered.length}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),

              //const SizedBox(height: 4),

              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState()
                    : _buildLecturasList(filtered),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLecturasList(List<Lectura> lecturas) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: lecturas.length,
      itemBuilder: (_, i) {
        final l = lecturas[i];

        return Card(
          //elevation: 1,
          color: Colors.white,
          //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () =>
                context.push('/lectura/${l.id}', extra: LecturaModo.editar),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Icon(Icons.water_drop, color: Colors.blue.shade600),
              ),
              title: Text(
                "Cuenta: ${l.cuenta}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "Lectura actual: ${l.lecturaActual}\nMedidor: ${l.medidor}\nPropietario: ${l.propietario}",
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: Colors.black45,
                size: 28,
              ),
            ),
          ),
        );

        
      },
    );
  }

  Widget _buildFilters(List<Ruta> rutas) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FiltersChipList(
        items: rutas,
        selectedId: selectedFilter,
        labelBuilder: (r) => r.detalle,
        valueBuilder: (r) => r.id,
        onSelected: (id) {
          setState(() => selectedFilter = id);
          ref.read(lecturasRegistradoslProvider.notifier).selectRuta(id);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 90, color: Colors.blue.shade600),
          const SizedBox(height: 20),
          const Text(
            "No se encontraron lecturas",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Prueba ajustando los filtros o la búsqueda.",
            style: TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
