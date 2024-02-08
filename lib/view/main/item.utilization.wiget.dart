import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/view/items/item.utilization.controller.dart';

class ItemUtilizationWidget extends ConsumerWidget {
  const ItemUtilizationWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemUtilization = ref.watch(itemUtilizationControllerProvider);
    return itemUtilization.when(
        data: (data) {
          return Row(
            children: [
              Expanded(
                child: Column(
                  children: [Text("${data.totalItemCount}"), const Text('Item Groups')],
                ),
              ),
              Expanded(
                child: Column(
                  children: [Text("${data.totalItemVariationsCount}"), const Text('Items')],
                ),
              ),
              Expanded(
                child: Column(
                  children: [Text("${data.totalQuantityOfAllItemVariation}"), const Text('Item Quanity')],
                ),
              ),
            ],
          );
        },
        error: (Object error, StackTrace stackTrace) {
          return const Text("error");
        },
        loading: () => const Center(
              child: CircularProgressIndicator(),
            ));
  }
}
