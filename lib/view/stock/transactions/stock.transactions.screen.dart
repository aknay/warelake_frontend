import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:warelake/view/main/drawer/drawer.dart';
import 'package:warelake/view/stock/transactions/add.transaction.modal.screen.dart';
import 'package:warelake/view/stock/transactions/filter.stock.transaction.screen.dart';
import 'package:warelake/view/stock/transactions/stock.transaction.list.view.dart';

class StockTransactionsScreen extends ConsumerWidget {
  const StockTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      drawer: const DrawerWidget(),
      floatingActionButton: FloatingActionButton(child: const Icon(Icons.add), onPressed: (){
         showModalBottomSheet(context: context, 
           constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.85), builder: (BuildContext context) => const AddTransactionModalScreen());
      }),
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
