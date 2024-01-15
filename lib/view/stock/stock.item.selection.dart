import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/view/items/item.list.view.dart';

class StockItemSelectionScreen extends ConsumerWidget {
  const StockItemSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Items")),
      body:  ItemListView(isToSelectItemVariation: true),
    );
  }
}
