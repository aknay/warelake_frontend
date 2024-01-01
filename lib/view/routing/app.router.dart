import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_frontend/data/auth/firebase.auth.repository.dart';
import 'package:inventory_frontend/data/onboarding/onboarding.service.dart';
import 'package:inventory_frontend/domain/stock.transaction/entities.dart';
import 'package:inventory_frontend/view/auth/custom.sign.in.screen.dart';
import 'package:inventory_frontend/view/bill.account/bill.account.screen.dart';
import 'package:inventory_frontend/view/bill.account/bill.accounts.screen.dart';
import 'package:inventory_frontend/view/items/add.item.screen.dart';
import 'package:inventory_frontend/view/items/add.item.variance.screen.dart';
import 'package:inventory_frontend/view/items/item.screen.dart';
import 'package:inventory_frontend/view/items/item.variaton.screen.dart';
import 'package:inventory_frontend/view/items/items.screen.dart';
import 'package:inventory_frontend/view/main/main.screen.dart';
import 'package:inventory_frontend/view/main/profile/profile.screen.dart';
import 'package:inventory_frontend/view/onboarding/onboarding.error.screen.dart';
import 'package:inventory_frontend/view/onboarding/onboarding.screen.dart';
import 'package:inventory_frontend/view/purchase.order/add.purchase.order.screen.dart';
import 'package:inventory_frontend/view/purchase.order/purchase.order.screen.dart';
import 'package:inventory_frontend/view/purchase.order/purchase.orders.screen.dart';
import 'package:inventory_frontend/view/routing/go_router_refresh_stream.dart';
import 'package:inventory_frontend/view/sale.orders/add.sale.order.screen.dart';
import 'package:inventory_frontend/view/sale.orders/line.item/add.line.item.screen.dart';
import 'package:inventory_frontend/view/sale.orders/line.item/item.selection/item.selection.screen.dart';
import 'package:inventory_frontend/view/sale.orders/sale.order.screen.dart';
import 'package:inventory_frontend/view/sale.orders/sale.orders.screen.dart';
import 'package:inventory_frontend/view/stock/stock.screen.dart';
import 'package:inventory_frontend/view/stock/stock.item.selection.dart';
import 'package:inventory_frontend/view/stock/transactions/stock.transaction.screen.dart';
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
  saleOrder,
  addSaleOrder,
  addLineItemForSaleOrder,
  itemsSelectionForSaleOrder,
  itemsSelectionForPurchaseOrder,
  selectItemForSaleOrder,
  selectItemForPurchaseOrder,
  purchaseOrders,
  purchaseOrder,
  addPurchaseOrder,
  addLineItemForPurchaseOrder,
  billAccounts,
  billAccount,
  variationItem,
  stockIn,
  selectStockLineItemForStockIn,
  selectItemForStockIn,
  stockTransactions,
  stockOut,
  selectStockLineItemForStockOut,
  selectItemForStockOut,
  stockAdjust,
  selectStockLineItemForStockAdjust,
  selectItemForStockAdjust,
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
        name: AppRoute.stockTransactions.name,
        path: '/stock_transactions',
        builder: (BuildContext context, GoRouterState state) {
          return const StockTransactionScreen();
        },
      ),
      GoRoute(
          name: AppRoute.stockIn.name,
          path: '/stock_in',
          builder: (BuildContext context, GoRouterState state) {
            return const StockScreen(stockMovement: StockMovement.stockIn);
          },
          routes: [
            GoRoute(
                name: AppRoute.selectStockLineItemForStockIn.name,
                path: 'select',
                builder: (BuildContext context, GoRouterState state) {
                  return const StockItemSelectionScreen();
                },
                routes: [
                  GoRoute(
                    name: AppRoute.selectItemForStockIn.name,
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ItemScreen(itemId: id, isToSelectItemVariation: true);
                    },
                  ),
                ]),
          ]),
      GoRoute(
          name: AppRoute.stockOut.name,
          path: '/stock_out',
          builder: (BuildContext context, GoRouterState state) {
            return const StockScreen(stockMovement: StockMovement.stockOut);
          },
          routes: [
            GoRoute(
                name: AppRoute.selectStockLineItemForStockOut.name,
                path: 'select',
                builder: (BuildContext context, GoRouterState state) {
                  return const StockItemSelectionScreen();
                },
                routes: [
                  GoRoute(
                    name: AppRoute.selectItemForStockOut.name,
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ItemScreen(itemId: id, isToSelectItemVariation: true);
                    },
                  ),
                ]),
          ]),
      GoRoute(
          name: AppRoute.stockAdjust.name,
          path: '/stock_adjust',
          builder: (BuildContext context, GoRouterState state) {
            return const StockScreen(stockMovement: StockMovement.stockAdjust);
          },
          routes: [
            GoRoute(
                name: AppRoute.selectStockLineItemForStockAdjust.name,
                path: 'select',
                builder: (BuildContext context, GoRouterState state) {
                  return const StockItemSelectionScreen();
                },
                routes: [
                  GoRoute(
                    name: AppRoute.selectItemForStockAdjust.name,
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ItemScreen(itemId: id, isToSelectItemVariation: true);
                    },
                  ),
                ]),
          ]),
      GoRoute(
          name: AppRoute.billAccounts.name,
          path: '/bill_accounts',
          builder: (BuildContext context, GoRouterState state) {
            return const BillAccountsScreen();
          },
          routes: [
            GoRoute(
              name: AppRoute.billAccount.name,
              path: ':id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return BillAccountScreen(billAccountId: id);
              },
            ),
          ]),
      GoRoute(
          name: AppRoute.purchaseOrders.name,
          path: '/purchase_orders',
          builder: (BuildContext context, GoRouterState state) {
            return const PurchaseOrdersScreen();
          },
          routes: <RouteBase>[
            GoRoute(
                name: AppRoute.addPurchaseOrder.name,
                path: 'add',
                builder: (context, state) {
                  return const AddPurchaseOrderScreen();
                },
                routes: <RouteBase>[
                  GoRoute(
                      name: AppRoute.addLineItemForPurchaseOrder.name,
                      path: 'line_item',
                      builder: (BuildContext context, GoRouterState state) {
                        return const AddLineItemScreen();
                      },
                      routes: <RouteBase>[
                        GoRoute(
                            name: AppRoute.itemsSelectionForPurchaseOrder.name,
                            path: 'item_selection',
                            builder: (BuildContext context, GoRouterState state) {
                              return const ItemSelectionScreen();
                            },
                            routes: [
                              GoRoute(
                                name: AppRoute.selectItemForPurchaseOrder.name,
                                path: ':id',
                                builder: (context, state) {
                                  final id = state.pathParameters['id']!;
                                  return ItemScreen(itemId: id, isToSelectItemVariation: true);
                                },
                              ),
                            ]),
                      ]),
                ]),
            GoRoute(
              name: AppRoute.purchaseOrder.name,
              path: ':id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return PurchaseOrderScreen(pruchaseOrderId: id, isToSelectItemVariation: false);
              },
            ),
          ]),
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
                      name: AppRoute.addLineItemForSaleOrder.name,
                      path: 'line_item',
                      builder: (BuildContext context, GoRouterState state) {
                        return const AddLineItemScreen();
                      },
                      routes: <RouteBase>[
                        GoRoute(
                            name: AppRoute.itemsSelectionForSaleOrder.name,
                            path: 'item_selection',
                            builder: (BuildContext context, GoRouterState state) {
                              return const ItemSelectionScreen();
                            },
                            routes: [
                              GoRoute(
                                name: AppRoute.selectItemForSaleOrder.name,
                                path: ':id',
                                builder: (context, state) {
                                  final id = state.pathParameters['id']!;
                                  return ItemScreen(itemId: id, isToSelectItemVariation: true);
                                },
                              ),
                            ]),
                      ]),
                ]),
            GoRoute(
              name: AppRoute.saleOrder.name,
              path: ':id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return SaleOrderScreen(saleOrderId: id, isToSelectItemVariation: false);
              },
            ),
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
                routes: [
                  GoRoute(
                    name: AppRoute.variationItem.name,
                    path: ':variation_item_id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      final variationItemId = state.pathParameters['variation_item_id']!;
                      return ItemVariationScreen(itemId: id, itemVariationId: variationItemId);
                    },
                  ),
                ]),
          ]),
    ],
  );
}
