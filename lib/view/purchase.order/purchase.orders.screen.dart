import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warelake/view/main/drawer/drawer.dart';
import 'package:warelake/view/purchase.order/purchase.order.list.view.dart';
import 'package:warelake/view/routing/app.router.dart';

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
          context.goNamed(AppRoute.addPurchaseOrder.name);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
