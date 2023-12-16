import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/view/sale.orders/sale.order.list.controller.dart';
import 'package:inventory_frontend/view/utils/async_value_ui.dart';

class SaleOrderListView extends ConsumerWidget {
  const SaleOrderListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue>(
      saleOrderListControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    final asyncItemList = ref.watch(saleOrderListControllerProvider);

    return asyncItemList.when(
        data: (data) {
          if (data.isEmpty) {
            return const Center(child: Text("Empty Sale Order"));
          }

          return ListView(
              children: data
                  .map((e) => ListTile(
                        title: Text(e.id!),
                        onTap: () {
                          // Navigator.pop(context, e);
                        },
                      ))
                  .toList());
        },
        error: (Object error, StackTrace stackTrace) => Text('Error: $error'),
        loading: () => const Center(child: CircularProgressIndicator()));
  }
}
