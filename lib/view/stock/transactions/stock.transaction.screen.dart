import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/data/stock.transaction/stock.transaction.service.dart';
import 'package:inventory_frontend/domain/stock.transaction/entities.dart';
import 'package:inventory_frontend/view/common.widgets/async_value_widget.dart';

final stockTransactionProvider = FutureProvider.autoDispose.family<StockTransaction, String>((ref, id) async {
  final itemOrError = await ref.watch(stockTransactionServiceProvider).get(stockTransactionId: id);
  if (itemOrError.isLeft()) {
    throw AssertionError("cannot item");
  }
  return itemOrError.toIterable().first;
});

class StockTransactionScreen extends ConsumerWidget {
  const StockTransactionScreen({super.key, required this.stockTransactionId});

  final String stockTransactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // return Scaffold(
    //   body: Column(children: [Text(stockTransaction.date)]),
    // );

    final jobAsync = ref.watch(stockTransactionProvider(stockTransactionId));
    return ScaffoldAsyncValueWidget<StockTransaction>(
      value: jobAsync,
      data: (job) => PageContents(stockTransaction: job),
    );
  }
}

class PageContents extends StatelessWidget {
  const PageContents({super.key, required this.stockTransaction});
  final StockTransaction stockTransaction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(stockTransaction.date)), body: Text("hello"));
  }
}
