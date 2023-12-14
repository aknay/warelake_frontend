import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/view/items/item.list.view.dart';

class ItemSelectionScreen extends ConsumerWidget {
  const ItemSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Items")),
      body: const ItemListView(),
    );
  }
}
