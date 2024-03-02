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
          return Container(
                          decoration: BoxDecoration(
                  color: Theme.of(context).highlightColor, borderRadius: const BorderRadius.all(Radius.circular(8))),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [Text("${data.totalItemCount}", style:  Theme.of(context).textTheme.headlineSmall),  Text('Item Groups', style: Theme.of(context).textTheme.labelSmall)],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [Text("${data.totalItemVariationsCount}", style:  Theme.of(context).textTheme.headlineSmall),  Text('Items', style: Theme.of(context).textTheme.labelSmall)],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [Text("${data.totalQuantityOfAllItemVariation}", style:  Theme.of(context).textTheme.headlineSmall),  Text('Stock', style:  Theme.of(context).textTheme.labelSmall)],
                    ),
                  ),
                ],
              ),
            ),
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
