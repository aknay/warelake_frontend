import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/view/bill.account.selection/bill.account.controller.dart';
import 'package:inventory_frontend/view/items/item.list.controller.dart';
import 'package:inventory_frontend/view/utils/async_value_ui.dart';

class BillAccountListView extends ConsumerWidget {
  const BillAccountListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue>(
      itemListControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    final asyncItemList = ref.watch(billAccountListControllerProvider);

    return asyncItemList.when(
        data: (data) {
          return ListView(
              children: data
                  .map((e) => ListTile(
                        title: Text(e.name),
                        onTap: () {
                          Navigator.pop(context, e);
                        },
                      ))
                  .toList());
        },
        error: (Object error, StackTrace stackTrace) => Text('Error: $error'),
        loading: () => const Center(child: CircularProgressIndicator()));
  }
}
