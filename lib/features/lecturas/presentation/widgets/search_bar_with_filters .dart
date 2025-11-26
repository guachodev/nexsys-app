import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';

class SearchBarWithFilters extends ConsumerStatefulWidget {
  final WidgetRef ref;

  const SearchBarWithFilters({required this.ref, super.key});

  @override
  ConsumerState<SearchBarWithFilters> createState() =>
      _SearchBarWithFiltersState();
}

class _SearchBarWithFiltersState extends ConsumerState<SearchBarWithFilters> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  FilterType selectedFilter = FilterType.medidor;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = widget.ref.watch(searchLecturaProvider);

    // Sincronizar el controller con el estado
    if (_controller.text != searchState.query) {
      _controller.value = _controller.value.copyWith(
        text: searchState.query,
        selection: TextSelection.collapsed(offset: searchState.query.length),
        composing: TextRange.empty,
      );
    }

    return Row(
      children: [
        Expanded(child: _buildSearchField(searchState)),
        /*  const SizedBox(width: 8),
        FilterButton(selectedFilter: selectedFilter, onSelected: (filter) {
          setState(() => selectedFilter = filter);
        }), */
      ],
    );
  }

  Widget _buildSearchField(SearchLecturaState searchState) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.number,
      onChanged: widget.ref.read(searchLecturaProvider.notifier).updateQuery,
      decoration: InputDecoration(
        hintText: _hintText(selectedFilter),
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        suffixIcon: searchState.query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  widget.ref
                      .read(searchLecturaProvider.notifier)
                      .updateQuery('');
                  _focusNode.requestFocus();
                },
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 12,
        ),
      ),
    );
  }

  String _hintText(FilterType filter) {
    switch (filter) {
      case FilterType.medidor:
        return 'Buscar por número de cuenta...';
      case FilterType.cedula:
        return 'Buscar por cédula...';
      case FilterType.catastro:
        return 'Buscar por catastro...';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

enum FilterType { medidor, cedula, catastro }
