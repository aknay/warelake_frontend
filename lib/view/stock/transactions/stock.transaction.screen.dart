import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/view/main/drawer.dart';
import 'package:inventory_frontend/view/stock/transactions/stock.transaction.list.view.dart';

class StockTransactionScreen extends ConsumerWidget {
  const StockTransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppBar(title: const Text("Stock Transactions")),
      body: const StockTransactionListView(),
    );
  }
}
