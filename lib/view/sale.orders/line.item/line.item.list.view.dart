import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_frontend/domain/purchase.order/entities.dart';
import 'package:inventory_frontend/view/routing/app.router.dart';
import 'package:inventory_frontend/view/sale.orders/line.item/line.item.controller.dart';
import 'package:inventory_frontend/view/sale.orders/line.item/selected.line.item.controller.dart';

class LineItemListView extends ConsumerWidget {
  const LineItemListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineItems = ref.watch(lineItemControllerProvider);
    ref.watch(selectedItemVariationProvider); // so that this will be still alive to be received in AddLineItemScreen
    if (lineItems.isEmpty) {
      return const Center(child: Text("Empty"));
    }
    return ListView(
      children: lineItems
          .map((e) => ListTile(
                title: Text(e.itemVariation.name),
                subtitle:
                    Row(children: [Text(e.quantity.toString()), const Text(" X "), Text(e.rateInDouble.toString())]),
                onTap: () {
                  _showDialog(context: context, lineItem: e, ref: ref);
                },
              ))
          .toList(),
    );
  }

  void _showDialog({required BuildContext context, required LineItem lineItem, required WidgetRef ref}) {
    final uri = GoRouter.of(context).routeInformationProvider.value.uri;
    final route = uri.path.contains('purchase_orders')
        ? AppRoute.addLineItemForPurchaseOrder.name
        : AppRoute.addLineItemForSaleOrder.name;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Dialog Title'),
          content: const Text('This is the dialog content.'),
          actions: [
            TextButton(
                onPressed: () {
                  ref.read(selectedItemVariationProvider.notifier).state = Some(lineItem.itemVariation);
                  context.goNamed(route, extra: lineItem);
                  Navigator.pop(context);
                },
                child: const Text('EDIT')),
            TextButton(
              onPressed: () {
                ref.read(lineItemControllerProvider.notifier).remove(lineItem: lineItem);
                Navigator.pop(context);
              },
              child: const Text(
                'DELETE',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ],
        );
      },
    );
  }
}
