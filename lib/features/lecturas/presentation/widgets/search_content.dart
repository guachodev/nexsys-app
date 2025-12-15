import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';
import 'package:nexsys_app/shared/widgets/widgets.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'lectura_item.dart';
import 'lectura_item_skeleton.dart';

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
          description: 'Introduce un texto en la barra de búsqueda para ver tus medidores asignados.',
        );

      case SearchStatus.empty:
        return BlankMessageScreen(
          icon: Icons.search_off_rounded,
          title: 'Resultado no encontrado',
          description:
              '¡No se encontraron medidores con ese criterio de búsqueda!',
        );

      case SearchStatus.loading:
        return Skeletonizer(
          enabled: true,
          child: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) =>  const LecturaItemSkeleton(),
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
