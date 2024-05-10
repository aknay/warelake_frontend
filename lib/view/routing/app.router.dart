import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:warelake/data/auth/firebase.auth.repository.dart';
import 'package:warelake/data/onboarding/team.service.dart';
import 'package:warelake/domain/purchase.order/entities.dart';
import 'package:warelake/view/auth/custom.sign.in.screen.dart';
import 'package:warelake/view/bill.account/bill.account.screen.dart';
import 'package:warelake/view/bill.account/bill.accounts.screen.dart';
import 'package:warelake/view/item.variations/add.item.variance.screen.dart';
import 'package:warelake/view/item.variations/item.variation.screen.dart';
import 'package:warelake/view/item.variations/item.variations.screen/item.variations.screen.dart';
import 'package:warelake/view/items/add.item.screen.dart';
import 'package:warelake/view/items/item.screen.dart';
import 'package:warelake/view/items/items.screen.dart';
import 'package:warelake/view/main/dashboard.screen.dart';
import 'package:warelake/view/main/low.stock.item.variation/low.stock.item.variations.screen.dart';
import 'package:warelake/view/main/profile/profile.screen.dart';
import 'package:warelake/view/onboarding/onboarding.error.screen.dart';
import 'package:warelake/view/onboarding/onboarding.screen.dart';
import 'package:warelake/view/orders/common.widgets/line.item/add.line.item.screen.dart';
import 'package:warelake/view/orders/common.widgets/line.item/item.selection/item.selection.screen.dart';
import 'package:warelake/view/orders/purchase.order/add.purchase.order.screen.dart';
import 'package:warelake/view/orders/purchase.order/purchase.order.screen.dart';
import 'package:warelake/view/orders/purchase.order/purchase.orders.screen.dart';
import 'package:warelake/view/orders/sale.orders/add.sale.order.screen.dart';
import 'package:warelake/view/orders/sale.orders/sale.order.screen.dart';
import 'package:warelake/view/orders/sale.orders/sale.orders.screen.dart';
import 'package:warelake/view/routing/go_router_refresh_stream.dart';
import 'package:warelake/view/stock/transactions/stock.transaction.screen.dart';
import 'package:warelake/view/stock/transactions/stock.transactions.screen.dart';

part 'app.router.g.dart';

enum AppRoute {
  items,
  signIn,
  dashboard,
  addItem,
  addItemFromDashboard,
  viewItem,
  addItemVariation,
  onboarding,
  onboardingError,
  profile,
  saleOrders,
  saleOrder,
  addSaleOrder,
  addSaleOrderFromDashboard,
  addLineItemForSaleOrder,
  addLineItemForSaleOrderFromDashboard,
  itemsSelectionForSaleOrder,
  itemsSelectionForSaleOrderFromDashboard,
  itemsSelectionForPurchaseOrder,
  itemsSelectionForPurchaseOrderFromDasboard,
  selectItemForSaleOrder,
  selectItemForSaleOrderFromDashboard,
  selectItemForPurchaseOrder,
  selectItemForPurchaseOrderFromDashboard,
  purchaseOrders,
  purchaseOrder,
  addPurchaseOrder,
  addPurchaseOrderFromDashboard,
  addLineItemForPurchaseOrder,
  addLineItemForPurchaseOrderFromDashboard,
  billAccounts,
  billAccount,
  variationItem,
  stockTransactions,
  stockTransactionDetail,
  itemVariations,
  itemVariationDetail,
  lowStockIteamVariations,
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
        final onboardingService = ref.watch(teamServiceProvider);
        final isCompletedOrError = await onboardingService.isOnboardingCompleted;
        return isCompletedOrError.fold((l) => '/error', (isCompleted) => isCompleted ? null : '/onboarding');
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
          routes: [
            GoRoute(
              name: AppRoute.lowStockIteamVariations.name,
              path: 'low_stock_item_variations',
              pageBuilder: (context, state) => const MaterialPage(
                fullscreenDialog: true,
                child: LowStockItemVariationsScreen(),
              ),
            ),
            GoRoute(
              name: AppRoute.addItemFromDashboard.name,
              path: 'add_item_from_dashboard',
              pageBuilder: (context, state) => const MaterialPage(
                fullscreenDialog: true,
                child: AddItemScreen(item: None()),
              ),
            ),
            GoRoute(
                name: AppRoute.addPurchaseOrderFromDashboard.name,
                path: 'add_purchase_order_from_dashboard',
                pageBuilder: (context, state) => const MaterialPage(
                      fullscreenDialog: true,
                      child: AddPurchaseOrderScreen(),
                    ),
                routes: <RouteBase>[
                  GoRoute(
                      name: AppRoute.addLineItemForPurchaseOrderFromDashboard.name,
                      path: 'line_item',
                      pageBuilder: (context, state) {
                        LineItem? lineItem = state.extra as LineItem?;
                        return MaterialPage(
                          fullscreenDialog: true,
                          child: AddLineItemScreen(lineItem: optionOf(lineItem)),
                        );
                      },
                      routes: <RouteBase>[
                        GoRoute(
                            name: AppRoute.itemsSelectionForPurchaseOrderFromDasboard.name,
                            path: 'item_selection',
                            builder: (BuildContext context, GoRouterState state) {
                              return const ItemSelectionScreen();
                            },
                            routes: [
                              GoRoute(
                                name: AppRoute.selectItemForPurchaseOrderFromDashboard.name,
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
                name: AppRoute.addSaleOrderFromDashboard.name,
                path: 'add_sale_order_from_dashboard',
                pageBuilder: (context, state) => const MaterialPage(
                      fullscreenDialog: true,
                      child: AddSaleOrderScreen(),
                    ),
                routes: <RouteBase>[
                  GoRoute(
                      name: AppRoute.addLineItemForSaleOrderFromDashboard.name,
                      path: 'line_item',
                      pageBuilder: (context, state) {
                        LineItem? lineItem = state.extra as LineItem?;
                        return MaterialPage(
                          fullscreenDialog: true,
                          child: AddLineItemScreen(lineItem: optionOf(lineItem)),
                        );
                      },
                      routes: <RouteBase>[
                        GoRoute(
                            name: AppRoute.itemsSelectionForSaleOrderFromDashboard.name,
                            path: 'item_selection',
                            builder: (BuildContext context, GoRouterState state) {
                              return const ItemSelectionScreen();
                            },
                            routes: [
                              GoRoute(
                                name: AppRoute.selectItemForSaleOrderFromDashboard.name,
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
        name: AppRoute.profile.name,
        path: '/profile',
        builder: (BuildContext context, GoRouterState state) {
          return const ProfileScreen();
        },
      ),
      GoRoute(
          name: AppRoute.itemVariations.name,
          path: '/item_variations',
          builder: (BuildContext context, GoRouterState state) {
            return const ItemVariationsScreen();
          },
          routes: [
            GoRoute(
              name: AppRoute.itemVariationDetail.name,
              path: ':id',
              builder: (context, state) {
                final itemVariationId = state.pathParameters['id']!;
                final itemId = state.uri.queryParameters['itemId']!;
                return ItemVariationScreen(itemId: itemId, itemVariationId: itemVariationId);
              },
            ),
          ]),
      GoRoute(
          name: AppRoute.stockTransactions.name,
          path: '/stock_transactions',
          builder: (BuildContext context, GoRouterState state) {
            return const StockTransactionsScreen();
          },
          routes: [
            GoRoute(
              name: AppRoute.stockTransactionDetail.name,
              path: ':id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return StockTransactionScreen(stockTransactionId: id);
              },
            ),
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
                      pageBuilder: (context, state) {
                        LineItem? lineItem = state.extra as LineItem?;
                        return MaterialPage(
                          fullscreenDialog: true,
                          child: AddLineItemScreen(lineItem: optionOf(lineItem)),
                        );
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
                      pageBuilder: (context, state) {
                        LineItem? lineItem = state.extra as LineItem?;
                        return MaterialPage(
                          fullscreenDialog: true,
                          child: AddLineItemScreen(lineItem: optionOf(lineItem)),
                        );
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
