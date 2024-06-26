import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/item/payloads.dart';
import 'package:warelake/view/common.widgets/async_value_widget.dart';
import 'package:warelake/view/common.widgets/dialogs/yes.no.dialog.dart';
import 'package:warelake/view/constants/app.sizes.dart';
import 'package:warelake/view/item.variations/async.item.variation.by.item.id.list.view.dart';
import 'package:warelake/view/item.variations/async.item.variation.list.by.item.id.controller.dart';
import 'package:warelake/view/items/edit.item.group.screen.dart';
import 'package:warelake/view/items/item.controller.dart';
import 'package:warelake/view/items/item.image/item.image.widget.dart';

enum ItemAction { delete }

class ItemScreen extends ConsumerWidget {
  const ItemScreen({super.key, required this.isToSelectItemVariation, required this.itemId});

  final String itemId;
  final bool isToSelectItemVariation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(itemControllerProvider(itemId: itemId));
    return ScaffoldAsyncValueWidget<Item>(
      value: jobAsync,
      data: (job) => PageContents(item: job, isToSelectItemVariation: isToSelectItemVariation),
    );
  }
}

class PageContents extends ConsumerWidget {
  const PageContents({super.key, required this.isToSelectItemVariation, required this.item});

  final Item item;
  final bool isToSelectItemVariation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: Text(item.name),
          actions: [
            IconButton(
                onPressed: () async {
                  ItemUpdatePayload? payload = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditItemGroupScreen(item: item),
                    ),
                  );

                  if (payload != null) {
                    await ref.read(itemControllerProvider(itemId: item.id!).notifier).updateItem(payload: payload);
                  }
                },
                icon: const Icon(Icons.edit)),
            PopupMenuButton<ItemAction>(
                onSelected: (ItemAction value) async {
                  switch (value) {
                    case ItemAction.delete:
                      if (context.mounted) {
                        final toDeleteOrNull = await showDialog<bool?>(
                          context: context,
                          builder: (BuildContext context) {
                            return const YesOrNoDialog(
                              actionWord: "Delete",
                              title: "Delete?",
                              content: "Are you sure you want to delete this item group?",
                            );
                          },
                        );

                        if (toDeleteOrNull != null && toDeleteOrNull) {
                          ref.read(itemControllerProvider(itemId: item.id!).notifier).deleteItem();
                        }
                      }
                  }
                },
                itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: ItemAction.delete,
                        child: Text('Delete'),
                      ),
                    ])
          ],
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          gapH16,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ItemImageWidget(itemId: item.id!, isForTheList: false),
            ],
          ),
          gapH8,
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text('Unit: ${item.unit}'),
          ),
          ..._getItemVariationView(ref, item.id!)
        ]));
  }

  List<Widget> _getItemVariationView(WidgetRef ref, String itemId) {
    final asyncItemVariations = ref.watch(asyncItemVariationListByItemIdControllerProvider(itemId: itemId));
    return asyncItemVariations.when(
        data: (data) {
          return [
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Text('Item Count: ${data.length}'),
            ),
            Expanded(
                child: AsyncItemVariationByItemIdListView(
              itemId: itemId,
              isToSelectItemVariation: isToSelectItemVariation,
            )),
          ];
        },
        error: (object, error) => [Text("$error")],
        loading: () => [const Center(child: CircularProgressIndicator())]);
  }
}
