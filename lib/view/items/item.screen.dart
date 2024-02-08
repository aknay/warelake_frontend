import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/data/item/item.service.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/item/payloads.dart';
import 'package:warelake/view/common.widgets/async_value_widget.dart';
import 'package:warelake/view/items/edit.item.screen.dart';
import 'package:warelake/view/items/item.list.controller.dart';
import 'package:warelake/view/items/item.list.view.dart';
import 'package:warelake/view/items/item.variation.list.view.dart';

final itemProvider = FutureProvider.autoDispose.family<Item, String>((ref, id) async {
  final itemOrError = await ref.watch(itemServiceProvider).getItem(itemId: id);
  if (itemOrError.isLeft()) {
    throw AssertionError("cannot item");
  }
  return itemOrError.toIterable().first;
});

class ItemScreen extends ConsumerWidget {
  const ItemScreen({super.key, required this.isToSelectItemVariation, required this.itemId});

  final String itemId;
  final bool isToSelectItemVariation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(itemProvider(itemId));
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
                      builder: (context) => EditItemScreen(item: Some(item)),
                    ),
                  );

                  if (payload != null) {
                    log("payload is okay");
                    final isSuccessful = await ref
                        .read(itemListControllerProvider.notifier)
                        .updateItem(payload: payload, itemId: item.id!);
                    if (isSuccessful) {
                      ref.invalidate(itemProvider);
                      ref.read(toForceToRefreshIemListProvider.notifier).state = !ref.read(toForceToRefreshIemListProvider);
                    }
                  }
                },
                icon: const Icon(Icons.edit)),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Text('Unit: ${item.unit}'),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Text('Count: ${item.variations.length}'),
            ),
            Expanded(
                child: ItemVariationListView(
                    itemVariationList: item.variations, isToSelectItemVariation: isToSelectItemVariation)),
          ],
        ));
  }
}
