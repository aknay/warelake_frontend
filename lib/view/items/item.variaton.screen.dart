import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/data/item/item.service.dart';
import 'package:inventory_frontend/domain/item/entities.dart';
import 'package:inventory_frontend/view/common.widgets/async_value_widget.dart';
import 'package:inventory_frontend/view/constants/app.sizes.dart';

final itemProvider = FutureProvider.family<Item, String>((ref, id) async {
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
    final billAccountAsync = ref.watch(itemProvider(itemId));

    return ScaffoldAsyncValueWidget<Item>(
      value: billAccountAsync,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemVariation = item.variations.where((r) => r.id == itemVariationId).first;

    return Scaffold(
        appBar: AppBar(
          title: Text(itemVariation.name),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Group Name"),
            Text(item.name),
            gapH8,
            const Text("Selling Price"),
            Text("${itemVariation.salePriceMoney.currency} ${itemVariation.salePriceMoney.amountInDouble}"),
            gapH8,
            const Text("Purchase Price"),
            Text("${itemVariation.purchasePriceMoney.currency} ${itemVariation.purchasePriceMoney.amountInDouble}"),
            gapH20,
            const Text("Stock Summary"),
            Row(
              children: [const Text("Stock on Hand:"), gapW8, Text("${itemVariation.itemCount}")],
            )
          ],
        ));
  }
}
