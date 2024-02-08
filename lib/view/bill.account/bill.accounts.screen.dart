import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/view/bill.account/bill.account.list.view.dart';
import 'package:inventory_frontend/view/main/drawer/drawer.dart';

class BillAccountsScreen extends ConsumerWidget {
  const BillAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppBar(title: const Text("Accounts")),
      body: const BillAccountListView(),
    );
  }
}
