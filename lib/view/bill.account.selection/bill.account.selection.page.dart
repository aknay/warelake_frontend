import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/view/bill.account.selection/bill.account.list.view.dart';

class BillAccountSelectionPage extends ConsumerWidget {
  const BillAccountSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Select a bill account")),
        body: const BillAccountListView(),
      ),
    );
  }
}
