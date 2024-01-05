import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/data/item/item.service.dart';
import 'package:inventory_frontend/domain/item/entities.dart';
import 'package:inventory_frontend/domain/item/payloads.dart';
import 'package:inventory_frontend/view/common.widgets/async_value_widget.dart';
import 'package:inventory_frontend/view/items/add.item.variance.screen.dart';
import 'package:inventory_frontend/view/items/item.list.controller.dart';

final itemProvider = FutureProvider.autoDispose.family<Item, String>((ref, id) async {
  if (foundation.kDebugMode) {
    await Future.delayed(const Duration(seconds: 1));
  }
  final itemOrError = await ref.watch(itemServiceProvider).getItem(itemId: id);
  if (itemOrError.isLeft()) {
    throw AssertionError("cannot item");
  }
  return itemOrError.toIterable().first;
});

class ItemVariationScreen extends ConsumerWidget {
  const ItemVariationScreen({required this.itemId, required this.itemVariationId, super.key});
  final String itemId;
  final String itemVariationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemProvider(itemId));

    return ScaffoldAsyncValueWidget<Item>(
      value: itemAsync,
      data: (data) => PageContents(
        item: data,
        itemVariationId: itemVariationId,
      ),
    );
  }
}

class PageContents extends ConsumerWidget {
  const PageContents({super.key, required this.item, required this.itemVariationId});
  final Item item;
  final String itemVariationId;

  Future<void> _edit(ItemVariation oldItemVariation, BuildContext context, WidgetRef ref) async {
    final ItemVariation? newItemVariation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemVariationScreen(itemVariation: oldItemVariation, hideStockLevelUi: true),
      ),
    );

    if (newItemVariation != null) {
      final payload = ItemVariationPayload(
        name: oldItemVariation.name == newItemVariation.name ? null : newItemVariation.name,
        pruchasePrice: oldItemVariation.purchasePriceMoney.amount == newItemVariation.purchasePriceMoney.amount
            ? null
            : newItemVariation.purchasePriceMoney.amountInDouble,
        salePrice: oldItemVariation.salePriceMoney.amount == newItemVariation.salePriceMoney.amount
            ? null
            : newItemVariation.salePriceMoney.amountInDouble,
      );

      final isSuccess = await ref.read(itemListControllerProvider.notifier).updateItemVariation(
          payload: payload, itemId: oldItemVariation.itemId!, itemVariationId: newItemVariation.id!);

      if (isSuccess) {
        ref.invalidate(itemProvider(item.id!));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemVariation = item.variations.where((r) => r.id == itemVariationId).first;
    final itemProviderState = ref.watch(itemProvider(item.id!));
    final itemListControllerState = ref.watch(itemListControllerProvider);

    if (itemProviderState.isLoading || itemListControllerState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(itemVariation.name)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(itemVariation.name),
          actions: [
            IconButton(
                onPressed: () async {
                  return itemProviderState.isLoading ? null : _edit(itemVariation, context, ref);
                },
                icon: const Icon(Icons.edit)),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text("Group Name"),
              trailing: Text(item.name, style: Theme.of(context).textTheme.bodyLarge),
            ),
            ListTile(
              title: const Text("Stock on hand"),
              trailing: Text("${itemVariation.itemCount}", style: Theme.of(context).textTheme.bodyLarge),
            ),
            ListTile(
              title: const Text("Selling Price"),
              trailing: Text("${itemVariation.salePriceMoney.currency} ${itemVariation.salePriceMoney.amountInDouble}",
                  style: Theme.of(context).textTheme.bodyLarge),
            ),
            ListTile(
              title: const Text("Purchase Price"),
              trailing: Text(
                  "${itemVariation.purchasePriceMoney.currency} ${itemVariation.purchasePriceMoney.amountInDouble}",
                  style: Theme.of(context).textTheme.bodyLarge),
            ),
          ],
        ));
  }
}
