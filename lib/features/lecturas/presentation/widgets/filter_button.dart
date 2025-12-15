import 'package:flutter/material.dart';
import 'package:nexsys_app/core/theme/theme.dart';

import 'search_bar_with_filters.dart';

class FilterButton extends StatelessWidget {
  final FilterType selectedFilter;
  final ValueChanged<FilterType> onSelected;

  const FilterButton(
      {required this.selectedFilter, required this.onSelected, super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<FilterType>(
      initialValue: selectedFilter,
      color: Colors.white,
      onSelected: onSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => [
        _filterOption(FilterType.medidor, 'Cuenta', Icons.speed),
        _filterOption(FilterType.cedula, 'Cédula', Icons.badge_outlined),
        _filterOption(FilterType.catastro, 'Catastro', Icons.map_outlined),
      ],
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(10),
        child: const Icon(Icons.tune, color: Colors.white),
      ),
    );
  }

  PopupMenuItem<FilterType> _filterOption(
      FilterType type, String label, IconData icon) {
    return PopupMenuItem(
      value: type,
      child: Row(
        children: [Icon(icon, color: AppColors.primary), const SizedBox(width: 8), Text(label)],
      ),
    );
  }
}