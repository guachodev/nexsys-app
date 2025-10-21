import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';
import 'package:nexsys_app/shared/widgets/widgets.dart';
import 'package:shimmer/shimmer.dart';

class SearchLecturaScreen extends ConsumerWidget {
  const SearchLecturaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchLecturaProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: const Text('Buscar Medidor')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                const _SearchBarWithFilters(),
                const SizedBox(height: 8),
                _buildContent(searchState),
                // Contenido dinámico según el estado
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildContent(SearchLecturaState searchState) {
  switch (searchState.status) {
    case SearchStatus.initial:
      return Expanded(
        child: BlankMessageScreen(
          icon: Icons.search,
          title: '',
          description: '¡Introduce el texto para buscar los medidores!',
          //buttonTitle: 'Recargar',
          //callback: () {},
        ),
      );

    case SearchStatus.empty:
      return Expanded(
        child: BlankMessageScreen(
          icon: Icons.add_box_rounded,
          title: 'Sin lecturas',
          description: '¡Introduce el texto para buscar los medidores!',
          buttonTitle: 'Recargar',
          callback: () {},
        ),
      );

    case SearchStatus.loading:
      return Expanded(
        child: ListView.builder(
          itemCount: 5,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemBuilder: (_, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      );

    case SearchStatus.loaded:
      return Expanded(
        child: ListView.builder(
          itemCount: searchState.lecturas.length,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemBuilder: (_, index) => FadeInUp(
            duration: const Duration(milliseconds: 250),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: LecturaItem(
                lectura: searchState.lecturas[index],
                onLecturaSelected: () {},
              ),
            ),
          ),
        ),
      );

    default:
      return const SizedBox();
  }
}

class _SearchBarWithFilters extends ConsumerStatefulWidget {
  const _SearchBarWithFilters();

  @override
  ConsumerState<_SearchBarWithFilters> createState() =>
      _SearchBarWithFiltersState();
}

class _SearchBarWithFiltersState extends ConsumerState<_SearchBarWithFilters> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  FilterType selectedFilter = FilterType.medidor;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();

    // Escucha cambios y notifica al provider
    _controller.addListener(() {
      ref.read(searchLecturaProvider.notifier).updateQuery(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchLecturaProvider);

    if (searchState.query != _controller.text) {
      _controller.value = TextEditingValue(
        text: searchState.query,
        selection: TextSelection.collapsed(offset: searchState.query.length),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Caja de texto
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: ref.read(searchLecturaProvider.notifier).updateQuery,
                decoration: InputDecoration(
                  hintText: _hintText(selectedFilter),
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: searchState.query.isNotEmpty
                      ? FadeIn(
                          child: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _controller.clear();
                              ref
                                  .read(searchLecturaProvider.notifier)
                                  .updateQuery('');
                              _focusNode.requestFocus();
                            },
                          ),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Botón de filtro
            PopupMenuButton<FilterType>(
              initialValue: selectedFilter,
              color: Colors.white,
              onSelected: (value) {
                setState(() => selectedFilter = value);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              itemBuilder: (context) => [
                _filterOption(FilterType.medidor, 'Medidor', Icons.speed),
                _filterOption(
                  FilterType.cedula,
                  'Cédula',
                  Icons.badge_outlined,
                ),
                _filterOption(
                  FilterType.catastro,
                  'Catastro',
                  Icons.map_outlined,
                ),
              ],
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(10),
                child: const Icon(Icons.tune, color: Colors.white),
              ),
            ),
          ],
        ),
        // const SizedBox(height: 8),
        Text('Filtro: ${_filterName(selectedFilter)}'),
        /*  Chip(
          label: Text('Filtro: ${_filterName(selectedFilter)}'),
          backgroundColor: Colors.indigo.shade50,
          labelStyle: const TextStyle(color: Colors.indigo),
        ), */
      ],
    );
  }

  PopupMenuItem<FilterType> _filterOption(
    FilterType type,
    String label,
    IconData icon,
  ) {
    return PopupMenuItem(
      value: type,
      child: Row(
        children: [
          Icon(icon, color: Colors.indigo),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  String _hintText(FilterType filter) {
    switch (filter) {
      case FilterType.medidor:
        return 'Buscar por número de medidor...';
      case FilterType.cedula:
        return 'Buscar por cédula...';
      case FilterType.catastro:
        return 'Buscar por catastro...';
      }
  }

  String _filterName(FilterType filter) {
    switch (filter) {
      case FilterType.medidor:
        return 'Medidor';
      case FilterType.cedula:
        return 'Cédula';
      case FilterType.catastro:
        return 'Catastro';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

enum FilterType {  medidor, cedula, catastro }
