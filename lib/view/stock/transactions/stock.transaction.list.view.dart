import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inventory_frontend/domain/stock.transaction/entities.dart';
import 'package:inventory_frontend/view/stock/stock.transaction.list.controller.dart';
import 'package:inventory_frontend/view/utils/async_value_ui.dart';

class StockTransactionListView extends ConsumerWidget {
  const StockTransactionListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue>(
      stockTransactionListControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    final asyncItemList = ref.watch(stockTransactionListControllerProvider);

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

  ListTile _getListTitle(StockTransaction stx, BuildContext context) {
    FaIcon icon;
    String stockMovementText;
    switch (stx.stockMovement) {
      case StockMovement.stockIn:
        icon = const FaIcon(FontAwesomeIcons.arrowDown);
        stockMovementText = "Stock In";
      case StockMovement.stockOut:
        icon = const FaIcon(FontAwesomeIcons.arrowUp);
        stockMovementText = "Stock Out";
      case StockMovement.stockAdjust:
        icon = const FaIcon(FontAwesomeIcons.arrowDownUpAcrossLine);
        stockMovementText = "Stock Adjust";
    }

    return ListTile(
      leading: icon,
      title: Text(stockMovementText),
      trailing: Text(stx.date),
      onTap: () {
        // context.goNamed(
        //   AppRoute.saleOrder.name,
        //   pathParameters: {'id': stx.id!},
        // );
        // Navigator.pop(context, e);
      },
      // trailing: Text(
      // " ${stx.currencyCodeEnum.name} ${stx.totalInDouble}",
      // style: Theme.of(context).textTheme.titleMedium,
      // ),
    );
  }
}
