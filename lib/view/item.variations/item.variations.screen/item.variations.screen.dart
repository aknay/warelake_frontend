import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/view/item.variations/item.variations.screen/item.variation.list.view/item.variation.search.widget.dart';
import 'package:warelake/view/item.variations/item.variations.screen/item.variations.list.view.dart';
import 'package:warelake/view/main/drawer/drawer.dart';

class ItemVariationsScreen extends ConsumerWidget {
  const ItemVariationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(title: const Text("Items")),
        drawer: const DrawerWidget(),
        body: const Column(
          children: [
            ItemVariationSearchWidget(),
            Expanded(
              child: ItemVariationListView(
                isToSelectItemVariation: false,
              ),
            ),
          ],
        ));
  }
}
