import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';
import 'package:nexsys_app/features/home/presentation/presentation.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';

import 'router_notifier.dart';

final goRouterProvider = Provider((ref) {
  final goRouterNotifier = ref.read(goRouterNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: goRouterNotifier,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const CheckScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/lecturas',
        builder: (context, state) => const LecturasScreen(),
      ),
      GoRoute(
        path: '/lecturas/search',
        builder: (context, state) => const SearchLecturaScreen(),
      ),
      /* GoRoute(
        path: '/lecturas/detalle/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return LecturaDetalleScreen(medidorId: id);
        },
      ), */
      GoRoute(
        path: '/lecturas/detalle', // /product/new
        builder: (context, state) {
          final lectura = state.extra as Lectura;
          return LecturaScreen(lecturaInicial: lectura);
        },
      ),
    ],

    redirect: (context, state) {
      final isGoingTo = state.fullPath;
      final authStatus = goRouterNotifier.authStatus;

      if (isGoingTo == '/splash' && authStatus == AuthStatus.checking) {
        return null;
      }

      if (authStatus == AuthStatus.notAuthenticated) {
        if (isGoingTo == '/login') return null;

        return '/login';
      }

      if (authStatus == AuthStatus.authenticated) {
        if (isGoingTo == '/login' || isGoingTo == '/splash') {
          return '/';
        }
      }

      return null;
    },
  );
});
