import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_frontend/data/auth/firebase.auth.repository.dart';
import 'package:inventory_frontend/view/auth/custom.sign.in.screen.dart';
import 'package:inventory_frontend/view/items/add.item.screen.dart';
import 'package:inventory_frontend/view/items/items.screen.dart';
import 'package:inventory_frontend/view/main/main.acreen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app.router.g.dart';

enum AppRoute {
  items,
  signIn,
  main,
  addItem,
}

@riverpod
GoRouter goRouter(GoRouterRef ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final _rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    initialLocation: '/sign_in',
    navigatorKey: _rootNavigatorKey,
    redirect: (context, state) {
      final isLoggedIn = authRepository.currentUser != null;
      final path = state.uri.path;
      if (isLoggedIn) {
        if (path.startsWith('/sign_in')) {
          return '/main';
        }
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        name: AppRoute.signIn.name,
        path: '/sign_in',
        builder: (BuildContext context, GoRouterState state) {
          return const CustomSignInScreen();
        },
      ),
      GoRoute(
        name: AppRoute.main.name,
        path: '/main',
        builder: (BuildContext context, GoRouterState state) {
          return const MainScreen();
        },
      ),
      GoRoute(
          name: AppRoute.items.name,
          path: '/items',
          builder: (BuildContext context, GoRouterState state) {
            return const ItemsScreen();
          },
          routes: <RouteBase>[
            GoRoute(
              name: AppRoute.addItem.name,
              path: 'add',
              builder: (context, state) => const AddItemScreen(),
            ),
          ]),
    ],
  );
}
