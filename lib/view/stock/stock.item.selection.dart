import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/view/items/item.list.view.dart';
import 'package:warelake/view/items/item.search.widget.dart';

class StockItemSelectionScreen extends ConsumerWidget {
  const StockItemSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select an item")),
      body: const Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
            child: ItemSearchWidget(),
          ),
          Expanded(child: ItemListView(isToSelectItemVariation: true)),
        ],
      ),
    );
  }
}
