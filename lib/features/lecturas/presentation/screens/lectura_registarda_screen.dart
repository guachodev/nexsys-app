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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
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

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => context.push('/lectura/${l.id}'),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------------- HEADER ----------------
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Cuenta",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l.cuenta.toString(),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ---- Botón Editar moderno ----
                        InkWell(
                          onTap: () => context.push('/lectura/${l.id}/edit'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  color: Colors.blue.shade600,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Editar",
                                  style: TextStyle(
                                    color: Colors.blue.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Divider(color: Colors.grey.shade200),

                    // ---------------- BODY DETAILS ----------------
                    const SizedBox(height: 12),

                    _modernInfoRow(Icons.speed, "Medidor", l.medidor),
                    _modernInfoRow(
                      Icons.person_outline,
                      "Propietario",
                      l.propietario,
                    ),
                    _modernInfoRow(
                      Icons.countertops_outlined,
                      "Lectura",
                      "${l.lecturaActual}",
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _modernInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: Colors.blue.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
