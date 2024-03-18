import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warelake/domain/purchase.order/entities.dart';
import 'package:warelake/view/constants/app.sizes.dart';
import 'package:warelake/view/orders/common.widgets/line.item/line.item.controller.dart';
import 'package:warelake/view/orders/common.widgets/line.item/selected.line.item.controller.dart';
import 'package:warelake/view/routing/app.router.dart';

class LineItemListView extends ConsumerWidget {
  const LineItemListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineItems = ref.watch(lineItemControllerProvider);
    ref.watch(selectedItemVariationProvider); // so that this will be still alive to be received in AddLineItemScreen
    if (lineItems.isEmpty) {
      return const Center(child: Text("No line item to display"));
    }

    final middle = lineItems
        .map((e) => ListTile(
              title: Text(e.itemVariation.name),
              subtitle:
                  Row(children: [Text(e.quantity.toString()), const Text(" X "), Text(e.rateInDouble.toString())]),
              trailing: Text("${e.totalAmount}", style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                _showDialog(context: context, lineItem: e, ref: ref);
              },
            ))
        .toList();

    const top = Row(children: [gapW16, Text('Items'), Spacer(), Text('Amount'), gapW20]);
    final total = lineItems.map((e) => e.totalAmount).fold(0.0, (previousValue, element) => previousValue + element);
    final bottom = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [const Text('Total:'), gapW8, Text('$total', style: Theme.of(context).textTheme.bodyLarge), gapW20]);
    return Column(children: [top, const Divider(), ...middle, const Divider(), bottom]);
  }

  void _showDialog({required BuildContext context, required LineItem lineItem, required WidgetRef ref}) {
    final router = GoRouter.of(context);

    final path = router.routeInformationProvider.value.uri.path;
    String nextRoute = '/';
    if (path == router.namedLocation(AppRoute.addPurchaseOrderFromDashboard.name)) {
      nextRoute = AppRoute.addLineItemForPurchaseOrderFromDashboard.name;
    } else if (path == router.namedLocation(AppRoute.addPurchaseOrder.name)) {
      nextRoute = AppRoute.addLineItemForPurchaseOrder.name;
    } else if (path == router.namedLocation(AppRoute.addSaleOrderFromDashboard.name)) {
      nextRoute = AppRoute.addLineItemForSaleOrderFromDashboard.name;
    } else if (path == router.namedLocation(AppRoute.addSaleOrder.name)) {
      nextRoute = AppRoute.addLineItemForSaleOrder.name;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit/Delete?'),
          actions: [
            TextButton(
                onPressed: () {
                  ref.read(selectedItemVariationProvider.notifier).state = Some(lineItem.itemVariation);
                  context.goNamed(nextRoute, extra: lineItem);
                  Navigator.pop(context);
                },
                child: const Text('EDIT')),
            TextButton(
              onPressed: () {
                ref.read(lineItemControllerProvider.notifier).remove(lineItem: lineItem);
                Navigator.pop(context);
              },
              child: const Text('REMOVE', style: TextStyle(color: Colors.redAccent)),
            ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ],
        );
      },
    );
  }
}
