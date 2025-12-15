import 'package:flutter/material.dart';
import 'package:nexsys_app/core/theme/theme.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';

class RutaSelectorBottomSheet extends StatefulWidget {
  final List<Ruta> rutas;
  final Ruta? selected;
  final Function(Ruta?) onSelected;
  final bool isSearch;

  const RutaSelectorBottomSheet({
    super.key,
    required this.rutas,
    required this.selected,
    required this.onSelected,
    this.isSearch = true,
  });

  @override
  State<RutaSelectorBottomSheet> createState() =>
      _RutaSelectorBottomSheetState();
}

class _RutaSelectorBottomSheetState extends State<RutaSelectorBottomSheet> {
  String _searchQuery = "";
  Ruta? rutaSelected;

  @override
  void initState() {
    super.initState();
    rutaSelected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    final rutasFiltradas = widget.rutas.where((r) {
      return r.detalle.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.40,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 60,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.only(top: 2, left: 12, right: 12),
            decoration: _headerDecoration(),
            child: Row(
              children: [
                const Text(
                  'Seleccionar Ruta',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade50,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),

          // Buscador
          if (widget.isSearch)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Buscar ruta...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
          Expanded(
            child: rutasFiltradas.isEmpty
                ? const Center(
                    child: Text(
                      'No hay resultados.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: rutasFiltradas.length,
                    itemBuilder: (_, i) {
                      final ruta = rutasFiltradas[i];
                      return _buildItem(
                        nombre: ruta.detalle,
                        id: ruta.id,
                        isSelected: rutaSelected?.id == ruta.id,
                        onTap: () {
                          widget.onSelected(ruta);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
           ],
      ),
    );
  }

  Widget _buildItem({
    required String nombre,
    required int id,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        Icons.directions,
        color: isSelected ? AppColors.primary : Colors.grey,
      ),
      title: Text(nombre),
      trailing: isSelected
          ? const Icon(Icons.check_rounded, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }

  BoxDecoration _headerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
    );
  }
}
