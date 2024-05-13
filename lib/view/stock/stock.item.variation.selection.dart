import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/view/constants/app.sizes.dart';
import 'package:warelake/view/item.variations/item.variations.screen/item.variation.list.view/item.variation.search.widget.dart';
import 'package:warelake/view/item.variations/item.variations.screen/item.variations.list.view.dart';

class StockItemVariationSelectionScreen extends ConsumerWidget {
  final ItemVariationSelection itemVariationSelection;

  const StockItemVariationSelectionScreen(this.itemVariationSelection, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(title: const Text("Items")),
        body: Column(
          children: [
            const ItemVariationSearchWidget(),
            gapH16,
            Expanded(
              child: ItemVariationListView(
                isToSelectItemVariation: true,
                itemVariationSelectionOrNone: Some(itemVariationSelection),
              ),
            ),
          ],
        ));
  }
}
