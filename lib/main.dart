import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/core/database/database.dart';
import 'package:nexsys_app/core/router/router.dart';
import 'package:nexsys_app/core/theme/theme.dart';

Future<void> main() async {
  await Environment.initEnvironment();
  // Inicializa la base de datos antes de correr la app
  await DatabaseProvider.db;
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'Flutter Demo',
      routerConfig: appRouter,
      theme: AppTheme.lightTheme,
    );
  }
}
