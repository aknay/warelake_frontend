import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_frontend/data/auth/firebase.auth.repository.dart';
import 'package:inventory_frontend/data/onboarding/onboarding.service.dart';
import 'package:inventory_frontend/view/auth/custom.sign.in.screen.dart';
import 'package:inventory_frontend/view/items/add.item.screen.dart';
import 'package:inventory_frontend/view/items/add.item.variance.screen.dart';
import 'package:inventory_frontend/view/items/item.screen.dart';
import 'package:inventory_frontend/view/items/items.screen.dart';
import 'package:inventory_frontend/view/main/main.screen.dart';
import 'package:inventory_frontend/view/main/profile/profile.screen.dart';
import 'package:inventory_frontend/view/onboarding/onboarding.error.screen.dart';
import 'package:inventory_frontend/view/onboarding/onboarding.screen.dart';
import 'package:inventory_frontend/view/routing/go_router_refresh_stream.dart';
import 'package:inventory_frontend/view/sale.orders/add.sale.order.screen.dart';
import 'package:inventory_frontend/view/sale.orders/line.item/add.line.item.screen.dart';
import 'package:inventory_frontend/view/sale.orders/line.item/item.selection/item.selection.screen.dart';
import 'package:inventory_frontend/view/sale.orders/sale.orders.screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app.router.g.dart';

enum AppRoute {
  items,
  signIn,
  dashboard,
  addItem,
  viewItem,
  addItemVariation,
  onboarding,
  onboardingError,
  profile,
  saleOrders,
  addSaleOrder,
  addLineItem,
  itemsSelection,
  selectItem,
}

@riverpod
GoRouter goRouter(GoRouterRef ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  return GoRouter(
    initialLocation: '/sign_in',
    navigatorKey: rootNavigatorKey,
    redirect: (context, state) async {
      final path = state.uri.path;
      log("path is $path");
      final isLoggedIn = await authRepository.isUserLoggedIn;

      log("is log? $isLoggedIn");

      // log("is loggin in $isLoggedIn");
      if (isLoggedIn) {
        if (path.startsWith('/sign_in')) {
          return '/dashboard';
        }
      } else {
        return '/sign_in';
      }

      if (path.startsWith('/dashboard')) {
        //we need to guard otherwise it will call after '\dashboard'
        final onboardingService = ref.watch(onboardingServiceProvider);
        final teamIdEmptyOrTeamListOrError = await onboardingService.isOnboardingCompleted;

        if (teamIdEmptyOrTeamListOrError.isLeft()) {
          return '/error';
        }
        final teamIdEmptyOrTeamList = teamIdEmptyOrTeamListOrError.toIterable().first;

        if (teamIdEmptyOrTeamList.isNone()) {
          if (path != '/onboarding') {
            return '/onboarding';
          }
        }
      }

      // no need to redirect at all
      return null;
    },
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges()),
    routes: <RouteBase>[
      GoRoute(
        name: AppRoute.signIn.name,
        path: '/sign_in',
        builder: (BuildContext context, GoRouterState state) {
          return const CustomSignInScreen();
        },
      ),
      GoRoute(
        path: '/onboarding',
        name: AppRoute.onboarding.name,
        pageBuilder: (context, state) => NoTransitionPage(child: OnboardingScreen()),
      ),
      GoRoute(
        name: AppRoute.onboardingError.name,
        path: '/error',
        builder: (context, state) => const OnboardingErrorScreen(),
      ),
      GoRoute(
        name: AppRoute.dashboard.name,
        path: '/dashboard',
        builder: (BuildContext context, GoRouterState state) {
          return const DashboardScreen();
        },
      ),
      GoRoute(
        name: AppRoute.profile.name,
        path: '/profile',
        builder: (BuildContext context, GoRouterState state) {
          return const ProfileScreen();
        },
      ),
      GoRoute(
          name: AppRoute.saleOrders.name,
          path: '/sale_orders',
          builder: (BuildContext context, GoRouterState state) {
            return const SaleOrdersScreen();
          },
          routes: <RouteBase>[
            GoRoute(
                name: AppRoute.addSaleOrder.name,
                path: 'add',
                builder: (context, state) {
                  return const AddSaleOrderScreen();
                },
                routes: <RouteBase>[
                  GoRoute(
                      name: AppRoute.addLineItem.name,
                      path: 'line_item',
                      builder: (BuildContext context, GoRouterState state) {
                        return const AddLineItemScreen();
                      },
                      routes: <RouteBase>[
                        GoRoute(
                            name: AppRoute.itemsSelection.name,
                            path: 'item_selection',
                            builder: (BuildContext context, GoRouterState state) {
                              return const ItemSelectionScreen();
                            },
                            routes: [
                              GoRoute(
                                name: AppRoute.selectItem.name,
                                path: ':id',
                                builder: (context, state) {
                                  final id = state.pathParameters['id']!;
                                  return ItemScreen(itemId: id, isToSelectItemVariation: true);
                                },
                              ),
                            ]),
                      ]),
                ]),
          ]),
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
                builder: (context, state) {
                  //  final jobId = state.pathParameters['item']!;
                  return const AddItemScreen(item: None());
                },
                routes: <RouteBase>[
                  GoRoute(
                    name: AppRoute.addItemVariation.name,
                    path: 'item_variation',
                    builder: (context, state) => const AddItemVariationScreen(),
                    // routes:
                  ),
                ]),
            GoRoute(
              name: AppRoute.viewItem.name,
              path: ':id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return ItemScreen(itemId: id, isToSelectItemVariation: false);
              },
            ),
          ]),
    ],
  );
}
