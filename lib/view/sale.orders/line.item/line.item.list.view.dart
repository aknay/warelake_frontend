import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/view/sale.orders/line.item/line.item.controller.dart';

class LineItemListView extends ConsumerWidget {
  const LineItemListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineItems = ref.watch(lineItemControllerProvider);
    if (lineItems.isEmpty) {
      return const Center(child: Text("Empty"));
    }
    return ListView(
      children: lineItems
          .map((e) => ListTile(
                title: Text(e.itemVariation.name),
                subtitle:
                    Row(children: [Text(e.quantity.toString()), const Text(" X "), Text(e.rateInDouble.toString())]),
                onTap: () {},
              ))
          .toList(),
    );
  }
}
