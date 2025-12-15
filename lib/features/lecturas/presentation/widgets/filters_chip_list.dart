import 'package:flutter/material.dart';

class FiltersChipList extends StatelessWidget {
  final List<dynamic> items; // Lista de rutas/elementos
  final int selectedId; // ID seleccionado actualmente
  final String Function(dynamic) labelBuilder; // Cómo convertir item → texto
  final int Function(dynamic) valueBuilder; // Cómo convertir item → int
  final ValueChanged<int> onSelected; // Callback al seleccionar

  const FiltersChipList({
    super.key,
    required this.items,
    required this.selectedId,
    required this.labelBuilder,
    required this.valueBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty || items.length <= 1) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        child: Row(
          children: items.map((item) {
            final id = valueBuilder(item);
            final label = labelBuilder(item);
            final selected = selectedId == id;

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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onSelected: (_) => onSelected(id),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
