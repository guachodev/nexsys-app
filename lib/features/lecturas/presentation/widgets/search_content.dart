import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/shared/widgets/widgets.dart';

import '../presentation.dart';
import 'lectura_item.dart';
import 'lectura_item_shimmer.dart';

class SearchContent extends StatelessWidget {
  final SearchLecturaState searchState;

  const SearchContent({required this.searchState, super.key});

  @override
  Widget build(BuildContext context) {
    switch (searchState.status) {
      case SearchStatus.initial:
        return BlankMessageScreen(
          icon: Icons.search,
          title: '',
          description: '¡Introduce el texto para buscar los medidores!',
        );

      case SearchStatus.empty:
        return BlankMessageScreen(
          icon: Icons.account_box_outlined,
          title: 'No se encontraron cuentas',
          description: '¡No se encontraron medidores con ese criterio de búsqueda!',
          //buttonTitle: 'Recargar',
          //callback: () {},
        );

      case SearchStatus.loading:
        return ListView.builder(
          itemCount: 5,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemBuilder: (_, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: const LecturaItemShimmer(),
          ),
        );

      case SearchStatus.loaded:
        return ListView.builder(
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
        );

      default:
        return const SizedBox();
    }
  }
}
