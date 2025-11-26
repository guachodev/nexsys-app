import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';
import 'package:nexsys_app/shared/widgets/widgets.dart';

class LecturasListScreen extends ConsumerStatefulWidget {
  const LecturasListScreen({super.key});

  @override
  ConsumerState<LecturasListScreen> createState() => _LecturasListScreenState();
}

class _LecturasListScreenState extends ConsumerState<LecturasListScreen> {
  String searchQuery = "";
  String filter = "todos"; // todos, registrados, sincronizados, pendientes

  @override
  void initState() {
    super.initState();

    // 🔹 Cargar lecturas automáticamente al entrar a la pantalla
    Future.microtask(() {
      ref.read(lecturasLocalProvider.notifier).cargarLecturas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lecturas = ref.watch(lecturasLocalProvider);

    final filtered = lecturas.where((l) {
      final matchesSearch =
          l.cuenta.toString().contains(searchQuery) ||
          l.medidor.contains(searchQuery) ||
          l.propietario.contains(searchQuery);

      if (!matchesSearch) return false;

      switch (filter) {
        case "registrados":
          return l.registrado;
        case "pendientes":
          return !l.registrado;
        case "sincronizados":
          return l.sincronizado;
        default:
          return true;
      }
    }).toList();

    return RefreshIndicator(
      onRefresh: () async =>
          ref.read(lecturasLocalProvider.notifier).cargarLecturas(),
      child: Scaffold(
        appBar: BarApp(title: "Lista de lecturas asignados"),
        /* floatingActionButton: FloatingActionButton.extended(
          label: const Text('Nuevo producto'),
          icon: const Icon(Icons.add),
          onPressed: () {
            context.push('/lectura/new');
          },
        ), */
        body: Column(
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
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                onChanged: (value) => setState(() => searchQuery = value),
              ),
            ),

            const SizedBox(height: 2),

            // 🔹 FILTROS
            _buildFilters(),

            /// const SizedBox(height: 12),

            // 🔸 TOTAL
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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

            const SizedBox(height: 8),

            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : _buildLecturasList(filtered),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _chip("Todos", "todos"),
          _chip("Registrados", "registrados"),
          _chip("Pendientes", "pendientes"),
          _chip("Sincronizados", "sincronizados"),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) {
    final selected = filter == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        checkmarkColor: Colors.white,
        selectedColor: Colors.blue.shade700,
        labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.black87,
          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (_) => setState(() => filter = value),
      ),
    );
  }

  Widget _buildLecturasList(List<Lectura> lecturas) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: lecturas.length,
      itemBuilder: (_, i) {
        final l = lecturas[i];

        return Card(
          elevation: 2,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            // onTap: () => context.push('/lectura/${l.id}'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ----------- HEADER -------------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue.shade50,
                        child: Icon(
                          Icons.water_drop,
                          size: 28,
                          color: Colors.blue.shade600,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Cuenta:",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              "${l.cuenta}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _statusBadge(l),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ----------- BODY DETAILS -------------
                  _infoRow("Medidor", l.medidor),
                  _infoRow("Propietario", l.propietario),
                  if (l.lecturaActual != null)
                    _infoRow("Lectura", l.lecturaActual.toString()),

                  _infoRow("x", l.latitud.toString()),
                  _infoRow("y", l.longitud.toString()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Row estilo detalle
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(Lectura l) {
    late Color color;
    late String text;
    late IconData icon;

    if (l.sincronizado) {
      color = Colors.green;
      text = "Sincronizado";
      icon = Icons.cloud_done_rounded;
    } else if (l.registrado && !l.sincronizado) {
      color = Colors.orange;
      text = "No sincronizado";
      icon = Icons.sync_rounded;
    } else {
      color = Colors.blueGrey;
      text = "Sin lectura";
      icon = Icons.edit_note_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // VISTA VACÍA
  // ---------------------------------------------------------------------------

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
