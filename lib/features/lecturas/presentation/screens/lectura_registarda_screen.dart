import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';
import 'package:nexsys_app/shared/widgets/widgets.dart';

class LecturaRegistardaScreen extends ConsumerStatefulWidget {
  const LecturaRegistardaScreen({super.key});

  @override
  ConsumerState<LecturaRegistardaScreen> createState() =>
      _LecturasListScreenState();
}

class _LecturasListScreenState extends ConsumerState<LecturaRegistardaScreen> {
  String searchQuery = "";

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
    final lecturas = ref.watch(lecturasRegistradoslProvider);

    final filtered = lecturas.where((l) {
      final matchesSearch =
          l.cuenta.toString().contains(searchQuery) ||
          l.medidor.contains(searchQuery) ||
          l.propietario.contains(searchQuery);

      return matchesSearch;
    }).toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: RefreshIndicator(
        onRefresh: () async =>
            ref.read(lecturasLocalProvider.notifier).filtrarPorRegistrado(1),
        child: Scaffold(
          appBar: BarApp(title: "Editar lecturas"),
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

              // 🔸 TOTAL
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
          color: Colors.white,
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => context.push('/lectura/${l.id}'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ----------- HEADER -------------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Cuenta:",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.black54
                              ),
                            ),
                            Text(
                              "${l.cuenta}",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // _statusChip(l.estado),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.blue.shade50,
                        child: Icon(
                          Icons.chevron_right,
                          size: 32,
                          color: Colors.blue.shade500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 2),

                  // ----------- BODY DETAILS -------------
                  _infoRow("Medidor", l.medidor),
                  _infoRow("Propietario", l.propietario),
                  _infoRow("Lectura", l.lecturaActual.toString()),
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
              fontWeight: FontWeight.w700,
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
