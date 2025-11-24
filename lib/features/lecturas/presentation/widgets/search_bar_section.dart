import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexsys_app/core/theme/theme.dart';
import 'package:nexsys_app/core/utils/utils.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';

import 'qr_scanner_sheet.dart';

class SearchBarSection extends StatelessWidget {
  final WidgetRef ref;
  final bool isCompleted;

  const SearchBarSection({
    required this.ref,
    required this.isCompleted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (isCompleted) return _showDone(context);
              ref.read(searchLecturaProvider.notifier).reset();
              context.push('/lecturas/search');
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black45, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.black54),
                  SizedBox(width: 8),
                  Text(
                    'Buscar cuenta...',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Material(
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              if (isCompleted) return _showDone(context);
              ref.read(searchLecturaQrProvider.notifier).reset();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                isDismissible: false,
                useSafeArea: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const QrScannerSheet(),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.barcode_reader,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDone(BuildContext context) {
    Notifications.show(context, icon: Icons.check_circle, title: '¡Completado!', message: 'Todas las lecturas han sido registradas correctamente.');
  }
}
