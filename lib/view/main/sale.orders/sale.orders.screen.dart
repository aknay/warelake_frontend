import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_frontend/view/main/drawer.dart';
import 'package:inventory_frontend/view/routing/app.router.dart';

class SaleOrdersScreen extends ConsumerWidget {
  const SaleOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppBar(title: Text("Sale Orders")),
      body: Center(child: Text("Sale Orders")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.goNamed(AppRoute.addSaleOrder.name);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
