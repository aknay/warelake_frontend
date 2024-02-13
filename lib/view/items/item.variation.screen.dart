import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/item/payloads.dart';
import 'package:warelake/view/common.widgets/async_value_widget.dart';
import 'package:warelake/view/common.widgets/dialogs/yes.no.dialog.dart';
import 'package:warelake/view/items/add.item.variance.screen.dart';
import 'package:warelake/view/items/item.controller.dart';
import 'package:warelake/view/routing/app.router.dart';

enum ItemVariationAction {
  delete,
}

class ItemVariationScreen extends ConsumerWidget {
  const ItemVariationScreen({required this.itemId, required this.itemVariationId, super.key});
  final String itemId;
  final String itemVariationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemControllerProvider(itemId: itemId));

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

      await ref
          .read(itemControllerProvider(itemId: oldItemVariation.itemId!).notifier)
          .updateItemVariation(payload: payload, itemVariationId: newItemVariation.id!);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemProviderState = ref.watch(itemControllerProvider(itemId: item.id!));

    if (itemProviderState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final itemVariations = item.variations.where((r) => r.id == itemVariationId);
    if (itemVariations.isEmpty) {
      ref.read(goRouterProvider).pop();
    }

    final itemVariation = itemVariations.first;

    return Scaffold(
        appBar: AppBar(
          title: Text(itemVariation.name),
          actions: [
            IconButton(
                onPressed: () async {
                  return itemProviderState.isLoading ? null : _edit(itemVariation, context, ref);
                },
                icon: const Icon(Icons.edit)),
            PopupMenuButton<ItemVariationAction>(
                onSelected: (ItemVariationAction value) async {
                  switch (value) {
                    case ItemVariationAction.delete:
                      if (context.mounted) {
                        final toDeleteOrNull = await showDialog<bool?>(
                          context: context,
                          builder: (BuildContext context) {
                            return const YesOrNoDialog(
                              actionWord: "Delete",
                              title: "Delete?",
                              content: "Are you sure you want to delete this item?",
                            );
                          },
                        );

                        if (toDeleteOrNull != null && toDeleteOrNull) {
                          await ref
                              .read(itemControllerProvider(itemId: item.id!).notifier)
                              .deleteItemVariation(itemVariationId: itemVariationId);
                        }
                      }
                  }
                },
                itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: ItemVariationAction.delete,
                        child: Text('Delete'),
                      ),
                    ])
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