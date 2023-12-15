import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_frontend/view/routing/app.router.dart';
import 'package:inventory_frontend/view/sale.orders/line.item/line.item.list.view.dart';

class AddSaleOrderScreen extends ConsumerStatefulWidget {
  const AddSaleOrderScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddSaleOrderScreenState();
}

class _AddSaleOrderScreenState extends ConsumerState<AddSaleOrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Sale Order"),
        actions: [
          IconButton(
              onPressed: () async {
                await _submit(ref: ref);
              },
              icon: const Icon(Icons.check)),
        ],
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () async {
              context.goNamed(
                AppRoute.addLineItem.name,
              );
            },
            child: const Text("Add Line Item"),
          ),
          const Expanded(child: LineItemListView())
        ],
      ),
    );
  }

  Future<void> _submit({required WidgetRef ref}) async {
    //   if (_validateAndSaveForm()) {
    //     final selectedItemVariationOrNone = ref.watch(selectedItemVariationProvider);
    //     final itemVariation = selectedItemVariationOrNone.toIterable().first;
    //     log("The rate is ${rate.toIterable().first}");
    //    final lineItem = LineItem.create(
    //         itemVariation: itemVariation,
    //         purchaseRate: rate.toIterable().first,
    //         purchaseQuantity: quantity.toIterable().first,
    //         unit: "some unit");
    //  ref.read(lineItemControllerProvider.notifier).add(lineItem);

    //     context.pop();
    //   }
  }
}
