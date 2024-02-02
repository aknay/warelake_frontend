import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/view/items/item.utilization.controller.dart';

class ItemUtilizationWidget extends ConsumerWidget {
  const ItemUtilizationWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemUtilization = ref.watch(itemUtilizationControllerProvider);
    return itemUtilization.when(
        data: (data) {
          return Row(
            children: [
              Column(
                children: [Text("${data.itemVariationCount}"), const Text('Items')],
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
