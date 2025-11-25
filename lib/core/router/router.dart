import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';
import 'package:nexsys_app/features/home/presentation/presentation.dart';
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
      GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
      GoRoute(
        path: '/lecturas',
        builder: (context, state) => const LecturasScreen(),
      ),
      GoRoute(
        path: '/lecturas/search',
        builder: (context, state) => const SearchLecturaScreen(),
      ),
      GoRoute(
        path: '/lecturas/registrados',
        builder: (context, state) => const LecturaRegistardaScreen(),
      ),
      GoRoute(
        path: '/lecturas/lista',
        builder: (context, state) => const LecturasListScreen(),
      ),
      GoRoute(
        path: '/lecturas/sincronizar',
        builder: (context, state) => const SincronizarScreen(),
      ),
      GoRoute(
        path: '/lecturas/detalle/:id',
        builder: (_, state) {
          final id = int.parse(state.pathParameters['id']!);
          return LecturaScreen(lecturaId: id);
        },
      ),
      GoRoute(
        path: '/lectura/:id', // /product/new
        builder: (context, state) =>
            EditarScreen(productId: state.pathParameters['id'] ?? 'no-id'),
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
