import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';
import 'package:nexsys_app/shared/widgets/widgets.dart';

import '../widgets/ruta_selector.dart';

class LecturasListaScreen extends ConsumerStatefulWidget {
  const LecturasListaScreen({super.key});

  @override
  ConsumerState<LecturasListaScreen> createState() =>
      _LecturasListaScreenState();
}

class _LecturasListaScreenState extends ConsumerState<LecturasListaScreen> {
  String searchQuery = "";
  String estado = "todos";

  int selectedRutaId = -1;
  String selectedRutaName = 'Todas las rutas';
  Ruta? rutaSeleccionada;
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(lecturasLocalProvider.notifier).cargarLecturas();
      ref.read(rutasProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lecturasState = ref.watch(lecturasLocalProvider);
    final rutasState = ref.watch(rutasProvider);
    final tieneUnaRuta = rutasState.rutas.length == 1;

    final filtered = lecturasState.lecturas.where((l) {
      final matchSearch =
          l.cuenta.toString().contains(searchQuery) ||
          l.medidor.toLowerCase().contains(searchQuery.toLowerCase()) ||
          l.cedula.toLowerCase().contains(searchQuery.toLowerCase());

      if (!matchSearch) return false;

      // --- Filtro Estado ---
      switch (estado) {
        case "registrados":
          if (!(l.registrado && !l.sincronizado)) return false;
          break;
        case "pendientes":
          if (l.registrado) return false;
          break;
        case "sincronizados":
          if (!l.sincronizado) return false;
          break;
      }

      // --- Filtro Ruta ---
      if (selectedRutaId != -1 && l.rutaId != selectedRutaId) {
        return false;
      }

      return true;
    }).toList();

    if (tieneUnaRuta) {
      selectedRutaName = rutasState.rutas.first.detalle;
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: RefreshIndicator(
        onRefresh: () async =>
            ref.read(lecturasLocalProvider.notifier).cargarLecturas(),
        child: Scaffold(
          appBar: BarApp(
            title: "Lista de Lecturas",
            actions: [
              ?tieneUnaRuta
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.filter_alt_outlined),
                      onPressed: () => _openRutasModal(rutasState.rutas),
                    ),
            ],
          ),

          body:
              lecturasState.status == SearchStatus.loading ||
                  lecturasState.status == SearchStatus.initial
              ? LoadingIndicator(
                  subtitle: 'Cargando lecturas espere un momento',
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Buscar por cuenta, medidor...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onChanged: (value) =>
                            setState(() => searchQuery = value),
                      ),

                      // -------------------------------------------------------
                      // FILTROS DE ESTADO
                      // -------------------------------------------------------
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _chip("Todos", "todos"),
                            _chip("Registrados", "registrados"),
                            _chip("Pendientes", "pendientes"),
                            _chip("Sincronizados", "sincronizados"),
                          ],
                        ),
                      ),

                      const SizedBox(height: 2),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Resultados: ${filtered.length}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            selectedRutaName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: filtered.isEmpty
                            ? _buildEmptyState()
                            : _buildLecturasList(filtered),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  // -------------------------------------------------------
  //  CHIP DE ESTADO
  // -------------------------------------------------------

  Widget _chip(String label, String value) {
    final selected = estado == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: Colors.blue.shade700,
        backgroundColor: Colors.white,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.black87,
          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (_) => setState(() => estado = value),
      ),
    );
  }

  // -------------------------------------------------------
  // MODAL PARA SELECCIONAR RUTA
  // -------------------------------------------------------

  Future<void> _openRutasModal(List<Ruta> rutas) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return RutaSelectorBottomSheet(
          rutas: rutas, // Lista de rutas
          selected: rutaSeleccionada ?? (rutas.isNotEmpty ? rutas.first : null),
          isSearch: false,
          onSelected: (ruta) {
            setState(() {
              rutaSeleccionada = ruta;
              selectedRutaId = ruta!.id;
              selectedRutaName = ruta.detalle;
            });
          },
        );
      },
    );

    /* showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Seleccionar Ruta",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              ...rutas.map((ruta) {
                return RadioListTile<int>(
                  title: Text(ruta.detalle),
                  value: ruta.id,
                  groupValue: selectedRutaId,
                  onChanged: (_) {
                    setState(() {
                      selectedRutaId = ruta.id;
                      selectedRutaName = ruta.detalle;
                    });
                    Navigator.pop(context);
                  },
                );
              }),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ); */
  }

  // -------------------------------------------------------
  // LISTADO
  // -------------------------------------------------------

  Widget _buildLecturasList(List<Lectura> lecturas) {
    return ListView.builder(
      // padding: const EdgeInsets.symmetric(horizontal: 16),
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                            const Text(
                              "Cuenta:",
                              style: TextStyle(
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
                  _infoRow("Medidor", l.medidor),
                  _infoRow("Propietario", l.propietario),
                  if (l.lecturaActual != null)
                    _infoRow("Lectura", l.lecturaActual.toString()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Expanded(child: Text(value)),
      ],
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
        color: color.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return BlankMessageScreen(
      icon: Icons.search_off,
      title: 'No se encontraron lecturas',
      description: 'Prueba ajustando filtros o búsqueda.',
    );
  }
}
