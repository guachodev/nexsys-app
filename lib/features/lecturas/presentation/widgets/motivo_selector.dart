import 'package:flutter/material.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';

class NovedadSelector extends StatefulWidget {
  final List<Novedad> items;
  final String? label;
  final String? hintText;
  final String? errorText;
  final Function(Novedad)? onChanged;
  final Novedad? initialValue;
  final bool? isSearch;

  const NovedadSelector({
    super.key,
    required this.items,
    this.errorText,
    this.onChanged,
    this.label,
    this.hintText,
    this.initialValue,
    this.isSearch = false,
  });

  @override
  MotivoSelectorState createState() => MotivoSelectorState();
}

class MotivoSelectorState extends State<NovedadSelector> {
  late Novedad? motivoSeleccionado;
  late TextEditingController _controller;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Inicializa el valor seleccionado
    motivoSeleccionado = widget.initialValue;

    _controller = TextEditingController(text: widget.initialValue?.name ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _mostrarBottomSheet() {
    // Reiniciar búsqueda al abrir el modal
    setState(() {
      _searchQuery = '';
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Filtrar motivos según la búsqueda
            final motivosFiltrados = widget.items.where((m) {
              return m.name.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.55,
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
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Seleccionar Novedad',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                  // Search field
                  if (widget.isSearch!)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Buscar novedad...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        onChanged: (value) {
                          setModalState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),

                  // Lista o mensaje vacío
                  Expanded(
                    child: motivosFiltrados.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay resultados para tu búsqueda.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: motivosFiltrados.length,
                            itemBuilder: (context, index) {
                              final motivo = motivosFiltrados[index];
                              final bool isSelected =
                                  motivoSeleccionado != null &&
                                  motivo.id == motivoSeleccionado!.id;

                              return Column(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  ListTile(
                                    dense: true,
                                    visualDensity: VisualDensity.compact,
                                    contentPadding: EdgeInsets.zero,
                                    minVerticalPadding: 0,
                                    title: Text(
                                      motivo.name,
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    trailing: isSelected
                                        ? const Icon(
                                            Icons.radio_button_checked,
                                            color: Colors.indigo,
                                          )
                                        : const Icon(
                                            Icons.radio_button_off_outlined,
                                            color: Colors.grey,
                                          ),
                                    onTap: () {
                                      setState(() {
                                        motivoSeleccionado = motivo;
                                        _controller.text = motivo.name;
                                      });
                                      widget.onChanged?.call(motivo);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  Divider(height: 1,thickness: 0.5,),
                                ],
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _mostrarBottomSheet,
      child: AbsorbPointer(
        child: TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelText: widget.label ?? 'Seleccionar',
            hintText: widget.hintText,
            suffixIcon: const Icon(Icons.chevron_right_rounded),
            errorText: widget.errorText,
          ),
          style: TextStyle(fontSize: 15),
        ),
      ),
    );
  }
}
