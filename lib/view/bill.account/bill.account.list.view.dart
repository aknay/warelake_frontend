import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warelake/view/bill.account.selection/bill.account.controller.dart';
import 'package:warelake/view/items/item.list.controller.dart';
import 'package:warelake/view/routing/app.router.dart';
import 'package:warelake/view/utils/async_value_ui.dart';

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
                        subtitle: Text("${e.currencyCodeAsEnum.name} ${e.balance}"),
                        onTap: () {
                          context.goNamed(
                            AppRoute.billAccount.name,
                            pathParameters: {'id': e.id!},
                          );
                          // Navigator.pop(context, e);
                        },
                      ))
                  .toList());
        },
        error: (Object error, StackTrace stackTrace) => Text('Error: $error'),
        loading: () => const Center(child: CircularProgressIndicator()));
  }
}
