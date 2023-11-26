import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/domain/item/entities.dart';

class ItemVariationListView extends ConsumerWidget {
  const ItemVariationListView({required this.itemVariationList, super.key});

  final List<ItemVariation> itemVariationList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (itemVariationList.isEmpty) {
      return const Center(child: Text("Please add at least one item variation."));
    }

      return ListView(
          children: itemVariationList.map((e) => ListTile(title: Text(e.name),)).toList(),
        );

    // return ListView.builder(
    //   // Let the ListView know how many items it needs to build.
    //   // itemCount: items.length,
    //   // Provide a builder function. This is where the magic happens.
    //   // Convert each item into a widget based on the type of item it is.
    //   itemBuilder: (context, index) {
    //     final item = itemVariationList[index];

    //     return ListTile(
    //       title: Text(item.name),
    //       // title: item.buildTitle(context),
    //       // subtitle: item.buildSubtitle(context),
    //     );
    //   },
    // );
  }
}
