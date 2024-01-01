import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_frontend/view/items/item.list.controller.dart';
import 'package:inventory_frontend/view/routing/app.router.dart';
import 'package:inventory_frontend/view/utils/async_value_ui.dart';

class ItemListView extends ConsumerWidget {
  final bool isToSelectItemVariation;
  const ItemListView({required this.isToSelectItemVariation, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue>(
      itemListControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    final asyncItemList = ref.watch(itemListControllerProvider);

    return asyncItemList.when(
        data: (data) {
          return ListView(
              children: data
                  .map((e) => ListTile(
                        title: Text(e.name),
                        onTap: () {
                          if (isToSelectItemVariation) {
                            final router = GoRouter.of(context);
                            final uri = router.routeInformationProvider.value.uri;

                            log("item list ${uri.path}");

                            if (uri.path.contains('stock_in')) {
                              context.goNamed(
                                AppRoute.selectItemForStockIn.name,
                                pathParameters: {'id': e.itemId!},
                              );
                            } else if (uri.path.contains('purchase_order')) {
                              context.goNamed(
                                AppRoute.selectItemForPurchaseOrder.name,
                                pathParameters: {'id': e.itemId!},
                              );
                            } else {
                              context.goNamed(
                                AppRoute.selectItemForSaleOrder.name,
                                pathParameters: {'id': e.itemId!},
                              );
                            }
                          } else {
                            context.goNamed(
                              AppRoute.viewItem.name,
                              pathParameters: {'id': e.itemId!},
                            );
                          }
                        },
                      ))
                  .toList());
        },
        error: (Object error, StackTrace stackTrace) => Text('Error: $error'),
        loading: () => const Center(child: CircularProgressIndicator()));
  }
}
