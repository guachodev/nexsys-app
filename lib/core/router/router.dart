import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/core/router/router_notifier.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';
import 'package:nexsys_app/features/home/presentation/presentation.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.read(goRouterNotifierProvider);
  //final session = ref.watch(sessionNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',

    //refreshListenable: Listenable.merge([routerNotifier]),
    refreshListenable: routerNotifier,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const CheckScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => ForgotPasswordScreen(),
      ),
      GoRoute(path: '/verify', builder: (context, state) => VerifyCodeScreen()),
      // admin 
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
      GoRoute(
        path: '/cuenta',
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: '/lecturas',
        builder: (context, state) => const LecturasScreen(),
      ),
      GoRoute(path: '/admin/local',
      builder: (context, state)=> const LocalAdminScreen()
      ),
      GoRoute(path: '/admin/local/images',
      builder: (context, state)=> const LocalImagesScreen()
      ),
      GoRoute(
        path: '/lecturas/search',
        builder: (context, state) => const SearchLecturaScreen(),
      ),
      GoRoute(
        path: '/lecturas/lista',
        builder: (context, state) => const LecturasListaScreen(),
      ),
      GoRoute(
        path: '/lecturas/sincronizar',
        builder: (context, state) => const SincronizarScreen(),
      ),
      GoRoute(
        path: '/lecturas/registrados',
        builder: (context, state) => const LecturaRegistardaScreen(),
      ),
      GoRoute(
        path: '/lectura/:id',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          final extra = state.extra;
          final modo = extra is LecturaModo ? extra : LecturaModo.registrar;
          return LecturaScreen(lecturaId: id, modo: modo);
        },
      ),
    ],
    redirect: (context, state) {
      final isGoingTo = state.fullPath;
      final authStatus = routerNotifier.authStatus;

      if (isGoingTo == '/splash' && authStatus == AuthStatus.checking) {
        return null;
      }

      if (authStatus == AuthStatus.notAuthenticated) {
        if (isGoingTo == '/login' ||
            isGoingTo == '/register' ||
            isGoingTo == '/forgot-password' ||
            isGoingTo == '/verify') {
          return null;
        }

        return '/login';
      }

      if (authStatus == AuthStatus.authenticated) {
        if (isGoingTo == '/login' ||
            isGoingTo == '/register' ||
            isGoingTo == '/splash' ||
            isGoingTo == '/forgot-password' ||
            isGoingTo == '/verify') {
          return '/';
        }
      }

      return null;
    },
  );
});
