import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/view/main/drawer/drawer.dart';
import 'package:warelake/view/orders/purchase.order/add.purchase.order.screen.dart';
import 'package:warelake/view/orders/purchase.order/purchase.order.list.view.dart';

class PurchaseOrdersScreen extends ConsumerWidget {
  const PurchaseOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppBar(title: const Text("Purchase Orders")),
      body: const PurchaseOrderListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPurchaseOrderScreen(), fullscreenDialog: true),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
