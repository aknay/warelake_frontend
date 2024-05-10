import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/stock.transaction/entities.dart';
import 'package:warelake/view/item.variations/add.item.variance.screen.dart';
import 'package:warelake/view/item.variations/item.variation.image/item.variation.image.widget.dart';
import 'package:warelake/view/item.variations/item.variation.list.controller.dart';
import 'package:warelake/view/orders/common.widgets/line.item/selected.line.item.controller.dart';
import 'package:warelake/view/routing/app.router.dart';
import 'package:warelake/view/stock/stock.line.item.list.view/stock.line.item.controller.dart';

class ItemVariationListView extends ConsumerWidget {
  const ItemVariationListView({required this.itemVariationList, required this.isToSelectItemVariation, super.key});

  final List<ItemVariation> itemVariationList;
  final bool isToSelectItemVariation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (itemVariationList.isEmpty) {
      return const Center(child: Text("Please add at least one item"));
    }

    return ListView(
      children: itemVariationList
          .map((e) => ListTile(
                leading: ItemVariationImageWidget(itemId: e.itemId, itemVariationId: e.id!, isForTheList: true),
                title: Text(e.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text("Stock on hand: ${e.itemCount}")],
                ),
                trailing: e.itemId == null
                    ? IconButton(
                        onPressed: () {
                          ref.read(itemVariationListControllerProvider.notifier).delete(e);
                        },
                        icon: const FaIcon(FontAwesomeIcons.xmark))
                    : const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  if (isToSelectItemVariation) {
                    ref.read(selectedItemVariationProvider.notifier).state = Some(e);

                    final router = GoRouter.of(context);
                    final uri = router.routeInformationProvider.value.uri;

                    final poOrSo =
                        uri.path.contains(router.namedLocation(AppRoute.addPurchaseOrderFromDashboard.name)) ||
                            uri.path.contains(router.namedLocation(AppRoute.addSaleOrderFromDashboard.name));

                    if (poOrSo) {
                      GoRouter.of(context).pop();
                      GoRouter.of(context).pop();
                    } else if (uri.path.contains('stock_in')) {
                      ref
                          .read(stockLineItemControllerProvider.notifier)
                          .add(StockLineItem.create(itemVariation: e, quantity: 1));
                    } else if (uri.path.contains('stock_out')) {
                      ref
                          .read(stockLineItemControllerProvider.notifier)
                          .add(StockLineItem.create(itemVariation: e, quantity: 1));
                    } else if (uri.path.contains('purchase_order')) {
                      context.goNamed(
                        AppRoute.addLineItemForPurchaseOrder.name,
                      );
                    } else {
                      context.goNamed(
                        AppRoute.addLineItemForSaleOrder.name,
                      );
                    }
                  } else {
                    if (e.itemId == null) {
                      //we want to edit local item variation
                      final ItemVariation? itemVariation = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddItemVariationScreen(itemVariation: Some(e)),
                        ),
                      );
                      if (itemVariation != null) {
                        ref.read(itemVariationListControllerProvider.notifier).upset(itemVariation);
                      }
                    } else {
                      context.goNamed(
                        AppRoute.variationItem.name,
                        pathParameters: {'id': e.itemId!, 'variation_item_id': e.id!},
                      );
                    }
                  }
                },
              ))
          .toList(),
    );
  }
}
