import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inventory_frontend/view/main/drawer/drawer.dart';
import 'package:inventory_frontend/view/stock/transactions/filter.stock.transaction.screen.dart';
import 'package:inventory_frontend/view/stock/transactions/stock.transaction.list.view.dart';

class StockTransactionsScreen extends ConsumerWidget {
  const StockTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppBar(
        title: const Text("Stock Transactions"),
        actions: [
          IconButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FilterStockTransactionScreen()),
                );
                // await _submit(ref: ref);
              },
              icon: const FaIcon(FontAwesomeIcons.filter)),
        ],
      ),
      body: const StockTransactionListView(),
    );
  }
}
