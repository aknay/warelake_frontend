import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warelake/data/stock.transaction/stock.transaction.service.dart';
import 'package:warelake/domain/stock.transaction/entities.dart';
import 'package:warelake/view/common.widgets/async_value_widget.dart';
import 'package:warelake/view/common.widgets/dialogs/yes.no.dialog.dart';
import 'package:warelake/view/routing/app.router.dart';
import 'package:warelake/view/stock/stock.transaction.list.controller.dart';

final stockTransactionProvider = FutureProvider.autoDispose.family<StockTransaction, String>((ref, id) async {
  final itemOrError = await ref.watch(stockTransactionServiceProvider).get(stockTransactionId: id);
  if (itemOrError.isLeft()) {
    throw AssertionError("cannot item");
  }
  return itemOrError.toIterable().first;
});

enum StockTransactionAction {
  delete,
}

class StockTransactionScreen extends ConsumerWidget {
  const StockTransactionScreen({super.key, required this.stockTransactionId});

  final String stockTransactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(stockTransactionProvider(stockTransactionId));
    ref.watch(stockTransactionListControllerProvider);
    return ScaffoldAsyncValueWidget<StockTransaction>(
      value: jobAsync,
      data: (job) => PageContents(stockTransaction: job),
    );
  }
}

class PageContents extends ConsumerWidget {
  const PageContents({super.key, required this.stockTransaction});
  final StockTransaction stockTransaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: Text(stockTransaction.date),
          actions: [
            PopupMenuButton<StockTransactionAction>(
                onSelected: (StockTransactionAction value) async {
                  switch (value) {
                    case StockTransactionAction.delete:
                      if (context.mounted) {
                        final toDeleteOrNull = await showDialog<bool?>(
                          context: context,
                          builder: (BuildContext context) {
                            return const YesOrNoDialog(
                              actionWord: "Delete",
                              title: "Delete?",
                              content: "Are you sure you want to delete this purchase order?",
                            );
                          },
                        );

                        if (toDeleteOrNull != null && toDeleteOrNull) {
                          final isSuccess =
                              await ref.read(stockTransactionListControllerProvider.notifier).delete(stockTransaction);
                          if (isSuccess && context.mounted) {
                            context.goNamed(AppRoute.stockTransactions.name);
                          }
                        }
                      }
                  }
                },
                itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: StockTransactionAction.delete,
                        child: Text('Delete'),
                      ),
                    ])
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(stockTransaction.stockMovement.description),
            Row(
              children: [
                Expanded(child: _toItemCount(stockTransaction)),
                Expanded(child: _toTotalItemCount(stockTransaction)),
              ],
            ),
            Expanded(child: _toLineItemList(stockTransaction))
          ],
        ));
  }

  Widget _toTotalItemCount(StockTransaction st) {
    final totalCount = st.lineItems.map((e) => e.quantity).fold(0, (previousValue, element) => previousValue + element);
    return Column(
      children: [Text("$totalCount"), const Text('Quantity')],
    );
  }

  Widget _toItemCount(StockTransaction st) {
    final totalCount = st.lineItems.length;
    return Column(
      children: [Text("$totalCount"), const Text('Item')],
    );
  }

  Widget _toLineItemList(StockTransaction st) {
    ListTile toListTile(StockLineItem sli) {
      String getSign(StockMovement sm) {
        switch (sm) {
          case StockMovement.stockIn:
            return '+';
          case StockMovement.stockOut:
            return '-';
          case StockMovement.stockAdjust:
            return '';
        }
      }

      return ListTile(
        title: Text(sli.itemVariation.name),
        trailing: Text("${getSign(st.stockMovement)} ${sli.quantity}"),
      );
    }

    return Column(
      children: st.lineItems.map((e) => toListTile(e)).toList(),
    );
  }
}
