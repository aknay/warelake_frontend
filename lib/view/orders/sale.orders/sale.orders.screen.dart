import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/view/main/drawer/drawer.dart';
import 'package:warelake/view/orders/sale.orders/add.sale.order.screen.dart';
import 'package:warelake/view/orders/sale.orders/sale.order.list.view.dart';

class SaleOrdersScreen extends ConsumerWidget {
  const SaleOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppBar(title: const Text("Sale Orders")),
      body: const SaleOrderListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddSaleOrderScreen(), fullscreenDialog: true),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
