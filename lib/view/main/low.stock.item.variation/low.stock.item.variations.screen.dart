import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/view/main/low.stock.item.variation/async.low.stock.item.variation.by.item.id.list.view.dart';

class LowStockItemVariationsScreen extends ConsumerWidget {
  const LowStockItemVariationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Low Stock"),
        ),
        body: const AsyncLowStockItemVariationListView());
  }
}
