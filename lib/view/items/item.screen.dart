import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/data/item/item.service.dart';
import 'package:inventory_frontend/domain/item/entities.dart';
import 'package:inventory_frontend/view/common.widgets/async_value_widget.dart';

final itemProvider = FutureProvider.family<Item, String>((ref, id) async {
  final itemOrError = await ref.watch(itemServiceProvider).getItem(itemId: id);
  if (itemOrError.isLeft()) {
    throw AssertionError("cannot item");
  }
  return itemOrError.toIterable().first;
});

class ItemScreen extends ConsumerWidget {
  const ItemScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(itemProvider(itemId));
    return ScaffoldAsyncValueWidget<Item>(
      value: jobAsync,
      data: (job) => PageContents(item: job),
    );
  }
}

class PageContents extends StatelessWidget {
  const PageContents({super.key, required this.item});
  final Item item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(item.name)), body: Text(item.name));
  }
}
