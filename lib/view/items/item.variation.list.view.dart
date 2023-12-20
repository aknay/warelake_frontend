import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_frontend/domain/item/entities.dart';
import 'package:inventory_frontend/view/routing/app.router.dart';
import 'package:inventory_frontend/view/sale.orders/line.item/selected.line.item.controller.dart';

class ItemVariationListView extends ConsumerWidget {
  const ItemVariationListView({required this.itemVariationList, required this.isToSelectItemVariation, super.key});

  final List<ItemVariation> itemVariationList;
  final bool isToSelectItemVariation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (itemVariationList.isEmpty) {
      return const Center(child: Text("Please add at least one item variation."));
    }

    return ListView(
      children: itemVariationList
          .map((e) => ListTile(
                title: Text(e.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_toSalePrice(e.salePriceMoney), _toPurchasePrice(e.purchasePriceMoney)],
                ),
                onTap: () {
                  if (isToSelectItemVariation) {
                    ref.read(selectedItemVariationProvider.notifier).state = Some(e);

                    final router = GoRouter.of(context);
                    final uri = router.routeInformationProvider.value.uri;

                    if (uri.path.contains('purchase_order')) {
                      context.goNamed(
                        AppRoute.addLineItemForPurchaseOrder.name,
                      );
                    } else {
                      context.goNamed(
                        AppRoute.addLineItemForSaleOrder.name,
                      );
                    }
                  }
                },
              ))
          .toList(),
    );
  }

  Text _toSalePrice(PriceMoney money) {
    return Text("Sale Price: ${money.currency} ${money.amount / 1000}");
  }

  Text _toPurchasePrice(PriceMoney money) {
    return Text("Purchase Price: ${money.currency} ${money.amount / 1000}");
  }
}
