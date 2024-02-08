import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warelake/domain/sale.order/entities.dart';
import 'package:warelake/view/routing/app.router.dart';
import 'package:warelake/view/sale.orders/sale.order.list.controller.dart';
import 'package:warelake/view/utils/async_value_ui.dart';

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

          return ListView(children: data.map((e) => _getListTitle(e, context)).toList());
        },
        error: (Object error, StackTrace stackTrace) => Text('Error: $error'),
        loading: () => const Center(child: CircularProgressIndicator()));
  }

  ListTile _getListTitle(SaleOrder so, BuildContext context) {
    return ListTile(
      title: Text(so.saleOrderNumber!),
      subtitle: Text(so.status!.toUpperCase()),
      onTap: () {
        context.goNamed(
          AppRoute.saleOrder.name,
          pathParameters: {'id': so.id!},
        );
        // Navigator.pop(context, e);
      },
      trailing: Text(
        " ${so.currencyCodeEnum.name} ${so.totalInDouble}",
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
