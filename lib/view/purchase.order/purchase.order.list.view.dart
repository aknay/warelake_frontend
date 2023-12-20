import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_frontend/domain/purchase.order/entities.dart';
import 'package:inventory_frontend/view/purchase.order/purchase.order.list.controller.dart';
import 'package:inventory_frontend/view/routing/app.router.dart';
import 'package:inventory_frontend/view/utils/async_value_ui.dart';

class PurchaseOrderListView extends ConsumerWidget {
  const PurchaseOrderListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue>(
      purchaseOrderListControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    final asyncItemList = ref.watch(purchaseOrderListControllerProvider);

    return asyncItemList.when(
        data: (data) {
          if (data.isEmpty) {
            return const Center(child: Text("Empty Purchase Order"));
          }

          return ListView(children: data.map((e) => _getListTitle(e, context)).toList());
        },
        error: (Object error, StackTrace stackTrace) => Text('Error: $error'),
        loading: () => const Center(child: CircularProgressIndicator()));
  }

  ListTile _getListTitle(PurchaseOrder po, BuildContext context) {
    return ListTile(
      title: Text(po.purchaseOrderNumber!),
      subtitle: Text(po.status.toUpperCase()),
      onTap: () {
        context.goNamed(
          AppRoute.purchaseOrder.name,
          pathParameters: {'id': po.id!},
        );
        // Navigator.pop(context, e);
      },
      trailing: Text(
        " ${po.currencyCodeEnum.name} ${po.totalInDouble}",
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
